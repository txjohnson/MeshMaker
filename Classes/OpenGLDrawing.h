/*
 *  OpenGLDrawing.h
 *  OpenGLEditor
 *
 *  Created by Filip Kunc on 6/22/09.
 *  For license see LICENSE.TXT
 *
 */

#pragma once

#import <Cocoa/Cocoa.h>
//#import <OpenGL/gl3.h>
#import <OpenGL/gl.h>
#import <OpenGL/glu.h>
#import "MathDeclaration.h"
#import "Enums.h"

void DrawCube(float size);
void DrawSphere(float radius, int lats, int longs);
void DrawCone(float width, float height, float offset);
void DrawLine(float size);
void DrawArrow(float size);
void DrawCubeArrow(float size);
void DrawCenterCube(float size);
void DrawPlane(float size, float sizeOffset);
void DrawCircle(float size);
void DrawPlane(Vector3D a, Vector3D b, float size);
void DrawSelectionPlane(PlaneAxis plane);