//
//  Mesh2.drawing.mm
//  OpenGLEditor
//
//  Created by Filip Kunc on 19.06.11.
//  Copyright 2011 Filip Kunc. All rights reserved.
//

#import "Mesh2.h"
#import "OpenGLDrawing.h"
#import "ShaderProgram.h"

void fillCachedColorsAtIndex(uint index, Vector3D *cachedColors, float components[3]);

void fillCachedColorsAtIndex(uint index, Vector3D *cachedColors, float components[3])
{
    for (uint j = 0; j < 3; j++)
    {
        for (uint k = 0; k < 3; k++)
        {
            cachedColors[index * 3 + j][k] = components[k];
        }
    }	
}

void Mesh2::resetTriangleCache()
{
    _cachedTriangleVertices.setValid(false);
    _cachedTriangleNormals.setValid(false);
    
	resetTriangleColorCache();    
    resetEdgeCache();
}

void Mesh2::resetTriangleColorCache()
{
    _cachedTriangleColors.setValid(false);
    
    resetEdgeCache();
}

void Mesh2::resetEdgeCache()
{
    _cachedEdgeVertices.setValid(false);
    _cachedEdgeColors.setValid(false);
}

void Mesh2::fillTriangleCache()
{
    if (_cachedTriangleVertices.isValid())
        return;
    
    _cachedTriangleVertices.resize(_triangles.count() * 3);
    _cachedTriangleNormals.resize(_triangles.count() * 3);
    _cachedVertexNormals.resize(_triangles.count() * 3);
    
    int i = 0;
    
    for (TriangleNode *node = _triangles.begin(), *end = _triangles.end(); node != end; node = node->next())
    {
        Triangle2 &currentTriangle = node->data;
        
        currentTriangle.computeNormal();
        Vector3D n = currentTriangle.normal;
        
        for (int j = 0; j < 3; j++)
        {
            _cachedTriangleVertices[i * 3 + j] = currentTriangle.vertex(j)->data.position;
            _cachedTriangleNormals[i * 3 + j] = n;
        }
        
        i++;
    }
    
    for (VertexNode *node = _vertices.begin(), *end = _vertices.end(); node != end; node = node->next())
    {
        node->computeNormal();
    }
    
    i = 0;
    
    for (TriangleNode *node = _triangles.begin(), *end = _triangles.end(); node != end; node = node->next())
    {
        Triangle2 &currentTriangle = node->data;
        
        for (int j = 0; j < 3; j++)
        {
            _cachedVertexNormals[i * 3 + j] = currentTriangle.vertex(j)->normal;
        }
        
        i++;
    }
    
    _cachedTriangleVertices.setValid(true);
    _cachedTriangleNormals.setValid(true);
    _cachedVertexNormals.setValid(true);
}

void Mesh2::fillTriangleColorCache()
{
    if (_cachedTriangleColors.isValid())
        return;
    
    _cachedTriangleColors.resize(_triangles.count() * 3);
    
    float selectedComponents[] = { 0.7f, 0.0f, 0.0f };
	
    uint i = 0;
	
    for (TriangleNode *node = _triangles.begin(), *end = _triangles.end(); node != end; node = node->next())
	{
		if (node->data.selected)
            fillCachedColorsAtIndex(i, _cachedTriangleColors, selectedComponents);
		else
            fillCachedColorsAtIndex(i, _cachedTriangleColors, _colorComponents);				
        
        i++;
	}
    
    _cachedTriangleColors.setValid(true);
}

void Mesh2::fillEdgeCache()
{
    if (_cachedEdgeVertices.isValid())
        return;
    
    _cachedEdgeVertices.resize(_edges.count() * 2);
    _cachedEdgeColors.resize(_edges.count() * 2);
    
    Vector3D selectedColor(0.8f, 0.0f, 0.0f);
    Vector3D normalColor(_colorComponents[0] - 0.2f, _colorComponents[1] - 0.2f, _colorComponents[2] - 0.2f);
    
    int i = 0;
    
    for (EdgeNode *node = _edges.begin(), *end = _edges.end(); node != end; node = node->next())
    {
        if (node->data.selected)
        {
            _cachedEdgeColors[i] = selectedColor;
            _cachedEdgeColors[i + 1] = selectedColor;
        }
        else
        {
            _cachedEdgeColors[i] = normalColor;
            _cachedEdgeColors[i + 1] = normalColor;
        }
        
        _cachedEdgeVertices[i] = node->data.vertex(0)->data.position;
        _cachedEdgeVertices[i + 1] = node->data.vertex(1)->data.position;
        
        i += 2;
    }

    _cachedEdgeVertices.setValid(true);
    _cachedEdgeColors.setValid(true);
}

void Mesh2::drawColoredFill(bool colored, bool useVertexNormals)
{
    fillTriangleCache();
	if (colored)
        fillTriangleColorCache();
    
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_NORMAL_ARRAY);
	if (colored)
	{
		glEnableClientState(GL_COLOR_ARRAY);
		float *colorPtr = (float *)&_cachedTriangleColors[0];
		glColorPointer(3, GL_FLOAT, 0, colorPtr);
	}
	
	float *vertexPtr = (float *)&_cachedTriangleVertices[0];
	float *normalPtr;
    
    if (useVertexNormals)
        normalPtr = (float *)&_cachedVertexNormals[0];
    else
        normalPtr = (float *)&_cachedTriangleNormals[0];
	
	glNormalPointer(GL_FLOAT, 0, normalPtr);
	glVertexPointer(3, GL_FLOAT, 0, vertexPtr);
	
	glDrawArrays(GL_TRIANGLES, 0, _triangles.count() * 3);
	
	if (colored)
		glDisableClientState(GL_COLOR_ARRAY);
    
    glDisableClientState(GL_NORMAL_ARRAY);
    glDisableClientState(GL_VERTEX_ARRAY);
}

void Mesh2::drawWire()
{
    if (_selectionMode != MeshSelectionModeEdges)
    {
        glColor3f(_colorComponents[0] - 0.2f, _colorComponents[1] - 0.2f, _colorComponents[2] - 0.2f);
        glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
        drawColoredFill(false, false);
        glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
    }
}

void Mesh2::draw(ViewMode mode, const Vector3D &scale, bool selected, bool forSelection)
{
	bool flipped = scale.x < 0.0f || scale.y < 0.0f || scale.z < 0.0f;
    ShaderProgram *shader = flipped ? [ShaderProgram flippedShader] : [ShaderProgram normalShader];
	
	glPushMatrix();
	glScalef(scale.x, scale.y, scale.z);
	if (mode == ViewModeWireframe)
	{
        if (!forSelection)
            glColor3f(_colorComponents[0] + 0.2f, _colorComponents[1] + 0.2f, _colorComponents[2] + 0.2f);
        
        glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
        drawColoredFill(false, false);
		glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
	}
	else if (forSelection)
	{
        drawColoredFill(false, false);
    }
    else
    {
		if (selected)
		{
			glEnable(GL_POLYGON_OFFSET_FILL);
			glPolygonOffset(1.0f, 1.0f);
            [shader useProgram];
            if (_selectionMode != MeshSelectionModeTriangles)
			{
				glColor3fv(_colorComponents);
                drawColoredFill(false, mode == ViewModeSolidGouraud);
			}
            else
            {
                drawColoredFill(true, mode == ViewModeSolidGouraud);
            }
			[ShaderProgram resetProgram];
			glDisable(GL_POLYGON_OFFSET_FILL);
            drawWire();
		}
		else
		{
            [shader useProgram];
            if (_selectionMode != MeshSelectionModeTriangles)
			{
				glColor3fv(_colorComponents);
                drawColoredFill(false, mode == ViewModeSolidGouraud);
			}
            else
            {
                drawColoredFill(true, mode == ViewModeSolidGouraud);
            }
            [ShaderProgram resetProgram];
		}
	}
	glPopMatrix();
}

void Mesh2::drawAtIndex(uint index, bool forSelection, ViewMode mode)
{
    switch (_selectionMode) 
	{
		case MeshSelectionModeVertices:
		{
            const Vertex2 &vertex = _cachedVertexSelection.at(index)->data;
			Vector3D v = vertex.position;
			if (!forSelection)
			{
				BOOL isSelected = vertex.selected;
				glPointSize(5.0f);
				if (isSelected)
					glColor3f(1.0f, 0.0f, 0.0f);
				else
					glColor3f(0.0f, 0.0f, 1.0f);
			}
			glBegin(GL_POINTS);
			glVertex3f(v.x, v.y, v.z);
			glEnd();
		} break;
		case MeshSelectionModeTriangles:
		{
			if (forSelection)
			{
				const Triangle2 &triangle = _cachedTriangleSelection.at(index)->data;
				glBegin(GL_TRIANGLES);
				for (uint i = 0; i < 3; i++)
				{
					Vector3D v = triangle.vertex(i)->data.position;
					glVertex3f(v.x, v.y, v.z);
				}
				glEnd();
			}
		} break;
        case MeshSelectionModeEdges:
        {
            const Edge2 &edge = _cachedEdgeSelection.at(index)->data;
            if (!forSelection)
            {
                BOOL isSelected = edge.selected;
                if (isSelected)
                    glColor3f(0.8f, 0.0f, 0.0f);
                else
                    glColor3f(_colorComponents[0] - 0.2f, _colorComponents[1] - 0.2f, _colorComponents[2] - 0.2f);
            }
            glBegin(GL_LINES);
            for (int i = 0; i < 2; i++)
            {
                Vector3D v = edge.vertex(i)->data.position;
                glVertex3f(v.x, v.y, v.z);
            }
            glEnd();
        } break;
        default:
            break;
	}
}

void Mesh2::drawAllVertices(ViewMode viewMode, bool forSelection)
{
    glPointSize(5.0f);
    
    if (forSelection)
    {
        vector<Vector3D> tempVertices;
        vector<uint> tempColors;
        
        uint colorIndex = 0;
        
        if (!_selectThrough)
        {
            glEnable(GL_POLYGON_OFFSET_FILL);
			glPolygonOffset(1.0f, 1.0f);
            glColor4ubv((GLubyte *)&colorIndex);
            drawColoredFill(false, false);
            glDisable(GL_POLYGON_OFFSET_FILL);
        }
        
        for (VertexNode *node = _vertices.begin(), *end = _vertices.end(); node != end; node = node->next())
        {
            colorIndex++;
            tempColors.push_back(colorIndex);            
            tempVertices.push_back(node->data.position);            
        }
        
        glEnableClientState(GL_VERTEX_ARRAY);
        glEnableClientState(GL_COLOR_ARRAY);
        
        GLubyte *colorPtr = (GLubyte *)&tempColors[0];
        glColorPointer(4, GL_UNSIGNED_BYTE, 0, colorPtr);
        
        float *vertexPtr = (float *)&tempVertices[0];        
        glVertexPointer(3, GL_FLOAT, 0, vertexPtr);
        
        glDrawArrays(GL_POINTS, 0, tempVertices.size());
        
        glDisableClientState(GL_COLOR_ARRAY);
        glDisableClientState(GL_VERTEX_ARRAY);
    }
    else
    {
        vector<Vector3D> tempVertices;
        vector<Vector3D> tempColors;
        
        Vector3D selectedColor(1.0f, 0.0f, 0.0f);
        Vector3D normalColor(0.0f, 0.0f, 1.0f);
        
        for (VertexNode *node = _vertices.begin(), *end = _vertices.end(); node != end; node = node->next())
        {
            if (node->data.selected)
                tempColors.push_back(selectedColor); 
            else if (_useSoftSelection && node->selectionWeight > 0.0f)
                tempColors.push_back(Vector3D(1.0f, 1.0f - node->selectionWeight, 0.0f));
            else
                tempColors.push_back(normalColor);
            
            tempVertices.push_back(node->data.position);            
        }
        
        glEnableClientState(GL_VERTEX_ARRAY);
        glEnableClientState(GL_COLOR_ARRAY);
        
        float *colorPtr = (float *)&tempColors[0];
        glColorPointer(3, GL_FLOAT, 0, colorPtr);
        
        float *vertexPtr = (float *)&tempVertices[0];        
        glVertexPointer(3, GL_FLOAT, 0, vertexPtr);
        
        glDrawArrays(GL_POINTS, 0, tempVertices.size());
        
        glDisableClientState(GL_COLOR_ARRAY);
        glDisableClientState(GL_VERTEX_ARRAY);
    }
}

void Mesh2::drawAllTriangles(ViewMode viewMode, bool forSelection)
{
    for (int i = 0; i < _triangles.count(); i++)
    {
        uint colorIndex = i + 1;
        glColor4ubv((GLubyte *)&colorIndex);
        drawAtIndex(i, forSelection, viewMode);
    }
}

void Mesh2::drawAllEdges(ViewMode viewMode, bool forSelection)
{
    fillEdgeCache();
    
    if (forSelection)
    {
        vector<uint> tempColors;
        
        uint colorIndex = 0;
        
        if (!_selectThrough)
        {
            glEnable(GL_POLYGON_OFFSET_FILL);
			glPolygonOffset(1.0f, 1.0f);
            glColor4ubv((GLubyte *)&colorIndex);
            drawColoredFill(false, false);
            glDisable(GL_POLYGON_OFFSET_FILL);
        }
        
        for (EdgeNode *node = _edges.begin(), *end = _edges.end(); node != end; node = node->next())
        {
            colorIndex++;
            tempColors.push_back(colorIndex);
            tempColors.push_back(colorIndex);
        }
        
        glEnableClientState(GL_VERTEX_ARRAY);
        glEnableClientState(GL_COLOR_ARRAY);
        
        GLubyte *colorPtr = (GLubyte *)&tempColors[0];
        glColorPointer(4, GL_UNSIGNED_BYTE, 0, colorPtr);
        
        float *vertexPtr = (float *)&_cachedEdgeVertices[0];
        glVertexPointer(3, GL_FLOAT, 0, vertexPtr);
        
        glDrawArrays(GL_LINES, 0, _edges.count() * 2);
        
        glDisableClientState(GL_COLOR_ARRAY);
        glDisableClientState(GL_VERTEX_ARRAY);
    }
    else
    {
        glEnableClientState(GL_VERTEX_ARRAY);
        glEnableClientState(GL_COLOR_ARRAY);
        
        float *colorPtr = (float *)&_cachedEdgeColors[0];
        glColorPointer(3, GL_FLOAT, 0, colorPtr);
        
        float *vertexPtr = (float *)&_cachedEdgeVertices[0];
        glVertexPointer(3, GL_FLOAT, 0, vertexPtr);
        
        glDrawArrays(GL_LINES, 0, _edges.count() * 2);
        
        glDisableClientState(GL_COLOR_ARRAY);
        glDisableClientState(GL_VERTEX_ARRAY);
    }
}

void Mesh2::drawAll(ViewMode mode, bool forSelection)
{
    switch (_selectionMode) 
	{
        case MeshSelectionModeVertices:
            drawAllVertices(mode, forSelection);
            break;
        case MeshSelectionModeTriangles:
            drawAllTriangles(mode, forSelection);
            break;
        case MeshSelectionModeEdges:
            drawAllEdges(mode, forSelection);
            break;
    }
}
