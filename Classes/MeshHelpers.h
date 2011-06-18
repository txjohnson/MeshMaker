/*
 *  MeshHelpers.h
 *  OpenGLEditor
 *
 *  Created by Filip Kunc on 10/23/09.
 *  For license see LICENSE.TXT
 *
 */

#pragma once

#import "Enums.h"
#import "MathDeclaration.h"
#import "SimpleNodeAndList.h"
#import <vector>
using namespace std;

struct Triangle
{
	uint vertexIndices[3];
};

struct Edge
{
	uint vertexIndices[2];
};

struct SelectionInfo
{
    bool selected;
    bool visible;
};

class Vertex2;
class Triangle2;

class VertexNode;
class TriangleNode;

class Vertex2
{
public:
    Vector3D position;
    
    bool selected;
    
    Vertex2() : selected(false) { }
    Vertex2(const Vector3D &v) : position(v), selected(false) { }    
};

class VertexNode : public FPNode<VertexNode, Vertex2>
{
private:
    SimpleList<Triangle2 *> triangles;
public:
    VertexNode() : FPNode<VertexNode, Vertex2>() { }
    VertexNode(const Vertex2 &vertex) : FPNode<VertexNode, Vertex2>(vertex) { } 
    virtual ~VertexNode() { }
    
    bool IsUsed() const { return triangles.count() > 0; }
    void AddTriangle(Triangle2 *triangle);
    void RemoveTriangle(Triangle2 *triangle);
    void RemoveFromTriangles();
    void ReplaceVertex(VertexNode *newVertex);
};

class Triangle2
{
private:
    VertexNode *vertices[3];
public:
    bool selected;
    
    Triangle2();
    Triangle2(VertexNode *v1, VertexNode *v2, VertexNode *v3);

    VertexNode *operator[](int index) const { return vertices[index]; }
    void ReplaceVertex(VertexNode *currentVertex, VertexNode *newVertex);
    void RemoveVertex(VertexNode *vertex);
    void AddToVertices();
    void RemoveFromVertices();
    bool IsDegenerated() const;
    bool IsVertexInTriangle(VertexNode *vertex) const;
    void GetVertexPositions(Vector3D vertexPositions[3]) const;
    void Flip();
};

class TriangleNode : public FPNode<TriangleNode, Triangle2>
{
public:
    TriangleNode() : FPNode<TriangleNode, Triangle2>() { }
    TriangleNode(const Triangle2 &triangle) : FPNode<TriangleNode, Triangle2>(triangle)
    {
        data.AddToVertices();
    }
    virtual ~TriangleNode()
    {
        data.RemoveFromVertices();
    }
};

Vector3D NormalFromTriangleVertices(Vector3D triangleVertices[3]);

void AddTriangle(vector<Triangle> &triangles, int index1, int index2, int index3);
void AddQuad(vector<Triangle> &triangles, int index1, int index2, int index3, int index4);
