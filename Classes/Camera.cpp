#include "Camera.h"

Camera::Camera()
{
	radians = Vector3D(0, 0, 0);
	minZoom = 0.1f;
	center = Vector3D(0, 0, 0);
	startPosition = Vector3D(0, 0, 300);
	position = Vector3D(0, 0, 300);
	startAxisX = Vector3D(1, 0, 0);
	startAxisY = Vector3D(0, 1, 0);
	startAxisZ = Vector3D(0, 0, 1);
	axisX = Vector3D(1, 0, 0);
	axisY = Vector3D(0, 1, 0);
	axisZ = Vector3D(0, 0, 1);
}

void Camera::ComputeVectors()
{
	Matrix4x4 rot;
    Quaternion q_x, q_y;
    Quaternion q_yx;
    q_x.FromAngleAxis(radians.x, startAxisX);
	q_y.FromAngleAxis(radians.y, startAxisY);
    q_yx = q_y * q_x;
    q_yx.ToMatrix(rot);
    axisX = startAxisX;
    axisZ = startAxisZ;
    axisX.Transform(rot);
    axisZ.Transform(rot);
    axisY = axisX.Cross(axisZ);

    position = startPosition;
    position -= center;
    position.Transform(q_yx);
    position += center;
}

float Camera::GetRadX() const
{
	return radians.x;
}

void Camera::SetRadX(float value)
{
	radians.x = value;
	ComputeVectors();
}
	
float Camera::GetRadY() const
{
	return radians.y;
}
	
void Camera::SetRadY(float value)
{
	radians.y = value;
	ComputeVectors();
}
	
float Camera::GetRadZ() const
{
	return radians.z;
}
	
void Camera::SetRadZ(float value)
{
	radians.z = value;
	ComputeVectors();
}

Vector3D Camera::GetRadians() const
{
	return radians;
}

void Camera::SetRadians(const Vector3D & newRadians)
{
	radians = newRadians;
	ComputeVectors();
}
	
float Camera::GetZoom() const
{
	return position.Distance(center);
}
	
void Camera::SetZoom(float value)
{
	float newZoom = position.Distance(center);
	newZoom -= value;
	Zoom(newZoom);
}
	
Vector3D Camera::GetCenter() const
{
	return center;	
}

void Camera::SetCenter(const Vector3D & v)
{
	MoveDirection(v - center);
}
	
Vector3D Camera::GetPosition() const
{
	return position;
}

void Camera::SetPosition(const Vector3D & v)
{
	MoveDirection(v - position);
}
	
Vector3D Camera::GetAxisX() const
{
	return axisX;
}
	
Vector3D Camera::GetAxisY() const
{
	return axisY;
}
	
Vector3D Camera::GetAxisZ() const
{
	return axisZ;
}
	
Matrix4x4 Camera::GetViewMatrix() const
{
	Matrix4x4 trans, rot;
    trans.Translate(-position);
    rot = GetRotationMatrix();    
    return (rot * trans);
}

Matrix4x4 Camera::GetRotationMatrix() const
{
	Matrix4x4 rot;
    Quaternion q_x, q_y, q;
    q_x.FromAngleAxis(-radians.x, startAxisX);
	q_y.FromAngleAxis(-radians.y, startAxisY);
    q = q_x * q_y;
    q.ToMatrix(rot);
    return rot;
}
	
void Camera::MoveDirection(const Vector3D & v)
{
	center += v;
	startPosition += v;
    position += v;
}
	
void Camera::Move(float s)
{
	MoveDirection(GetAxisZ() * s);
}
	
void Camera::LeftRight(float s)
{
    MoveDirection(GetAxisX() * s);
}
	
void Camera::UpDown(float s)
{
	MoveDirection(GetAxisY() * s);
}
	
void Camera::RotateLeftRight(float radians)
{
	this->radians.y -= radians;
	ComputeVectors();
}
	
void Camera::RotateUpDown(float radians)
{
	this->radians.x -= radians;
	ComputeVectors();
}

void Camera::Zoom(float zoom)
{
	float currentZoom = GetZoom();
	if (zoom > currentZoom - minZoom)
        zoom = currentZoom - minZoom;
    startPosition -= startAxisZ * zoom;
    position -= axisZ * zoom;
}
