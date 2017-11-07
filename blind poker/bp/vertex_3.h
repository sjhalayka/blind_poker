
#ifndef vertex_3_h
#define vertex_3_h





#include <cmath>
#include <cstddef> // Include this for the sake of g++, or it will not recognize size_t




class vertex_3
{
public:
    inline vertex_3(void) : x(0.0f), y(0.0f), z(0.0f) {}
    inline vertex_3(const double src_x, const double src_y, const double src_z) : x(src_x), y(src_y), z(src_z) {}
    inline vertex_3(const vertex_3 &rhs) : x(rhs.x), y(rhs.y), z(rhs.z) {}
    
    inline bool operator==(const vertex_3 &right) const
    {
        if(x == right.x && y == right.y && z == right.z)
            return true;
        
        return false;
    }
                
    inline bool operator<(const vertex_3 &right) const
    {
        
        if(x < right.x)
            return true;
        else if(x > right.x)
            return false;
        
        if(y < right.y)
            return true;
        else if(y > right.y)
            return false;
        
        if(z < right.z)
            return true;
        else if(z > right.z)
            return false;
        
        return false;
    }
    
    inline bool operator>(const vertex_3 &right) const
    {
        if(x > right.x)
            return true;
        else if(x < right.x)
            return false;
        
        if(y > right.y)
            return true;
        else if(y < right.y)
            return false;
        
        if(z > right.z)
            return true;
        else if(z < right.z)
            return false;
        
        return false;
    }
    
    
    inline vertex_3& operator+=(const vertex_3 &right)
    {
        x += right.x;
        y += right.y;
        z += right.z;
        
        return *this;
    }
    
    inline vertex_3& operator*=(const double &right)
    {
        x *= right;
        y *= right;
        z *= right;
        
        return *this;
    }
    
    inline vertex_3& operator=(const vertex_3 &right)
    {
        x = right.x;
        y = right.y;
        z = right.z;
        
        return *this;
    }
    
    inline vertex_3 operator-(const vertex_3 &right) const
    {
        vertex_3 temp;
        
        temp.x = x - right.x;
        temp.y = y - right.y;
        temp.z = z - right.z;
        
        return temp;
    }
    
    inline vertex_3 operator+(const vertex_3 &right) const
    {
        vertex_3 temp;
        
        temp.x = x + right.x;
        temp.y = y + right.y;
        temp.z = z + right.z;
        
        return temp;
    }
    
    inline vertex_3 operator*(const double &right) const
    {
        vertex_3 temp;
        
        temp.x = x * right;
        temp.y = y * right;
        temp.z = z * right;
        
        return temp;
    }
    
    inline vertex_3 operator/(const double &right) const
    {
        vertex_3 temp;
        
        temp.x = x / right;
        temp.y = y / right;
        temp.z = z / right;
        
        return temp;
    }
    
    inline vertex_3 cross(const vertex_3 &right) const
    {
        vertex_3 temp;
        
        temp.x = y*right.z - z*right.y;
        temp.y = z*right.x - x*right.z;
        temp.z = x*right.y - y*right.x;
        
        return temp;
    }
    
    inline double dot(const vertex_3 &right) const
    {
        return x*right.x + y*right.y + z*right.z;
    }
    
    inline double self_dot(void) const
    {
        return x*x + y*y + z*z;
    }
    
    inline double length(void) const
    {
        return sqrt(self_dot());
    }
    
    inline double distance(const vertex_3 &right) const
    {
        return sqrt((right.x - x)*(right.x - x) + (right.y - y)*(right.y - y) + (right.z - z)*(right.z - z));
    }
    
    inline double distance_sq(const vertex_3 &right) const
    {
        return (right.x - x)*(right.x - x) + (right.y - y)*(right.y - y) + (right.z - z)*(right.z - z);
    }
    
    inline void normalize(void)
    {
        double len = length();
        
        if(0.0f != len)
        {
            x /= len;
            y /= len;
            z /= len;
        }
    }
    
    inline void zero(void)
    {
        x = y = z = 0;
    }
    
    inline void rotate_x(const double &radians)
    {
        double t_y = y;
        
        y = t_y*cos(radians) + z*sin(radians);
        z = t_y*-sin(radians) + z*cos(radians);
    }
    
    inline void rotate_y(const double &radians)
    {
        double t_x = x;
        
        x = t_x*cos(radians) + z*-sin(radians);
        z = t_x*sin(radians) + z*cos(radians);
    }
    
    inline void rotate_z(const double &radians)
    {
        double t_x = x;
        
        x = t_x*cos(radians) + y*sin(radians);
        y = t_x*-sin(radians) + y*cos(radians);
    }
    
    double x, y, z;
};



#endif
