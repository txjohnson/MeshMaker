//
//  FPList.h
//  GLMotionMaker
//
//  Created by Filip Kunc on 10/15/10.
//  For license see LICENSE.TXT
//

#pragma once

template <class TNode, class TData>
class FPList
{
private:
    TNode *_begin;
    TNode *_end;
    int _count;
public:
    FPList()
    {
        _begin = new TNode();
        _end = new TNode();
        
        _begin->_next = _end;
        _end->_previous = _begin;
        _count = 0;
    }
    
    virtual ~FPList()
    {
        removeAll();
        delete _begin;
        delete _end;
    }
    
    TNode *begin() { return _begin->_next; }
    TNode *end() { return _end; }
    
    TNode *first(int n) const
    {
        TNode *current = _begin->_next;
        
        int i = 0;
        
        while (current != _end)
        {
            TNode *next = current->_next;
            
            if (i == n)
                return current;
            
            current = next;
        }
        
        return NULL;
    }
    
    TNode *last(int n) const
    {
        TNode *current = _end->_previous;
        
        int i = 0;
        
        while (current != _begin)
        {
            TNode *next = current->_previous;
            
            if (i == n)
                return current;
            
            current = next;
        }
        
        return NULL;
    }    
    
    TNode *first() const
    {
        if (_begin->_next != _end)
            return _begin->_next;
        return NULL;
    }
    
    TNode *last() const
    {
        if (_end->_previous != _begin)
            return _end->_previous;
        return NULL;
    }
    
    int count() const
    {
        return _count;
    }
    
    void remove(TNode *&node)
    {
        TNode *next = node->_next;
        TNode *previous = node->_previous;
    
        next->_previous = previous;
        previous->_next = next;
        
        delete node;
        
        node = previous;
        
        _count--;
    }
    
    void removeAll()
    {
        TNode *current = _begin->_next;
        
        while (current != _end)
        {
            current = current->_next;
            delete current->_previous;
        }
        
        _begin->_next = _end;
        _end->_previous = _begin;
        
        _count = 0;
    }
    
    TNode *add(const TData &data)
    {
        TNode *newOne = new TNode(data);
        TNode *previous = _end->_previous;
        newOne->_next = _end;
        newOne->_previous = previous;
        previous->_next = newOne;
        _end->_previous = newOne;
        
        _count++;
        
        return newOne;
    }   
};

