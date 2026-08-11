#include "Producto.h"

// Constructor: valida que el precio no sea negativo (punto h - excepciones)
Producto::Producto(std::string id, std::string nombre, float precio) {
    if (precio < 0) {
        throw std::invalid_argument("Error: el precio no puede ser negativo.");
    }
    this->id      = id;
    this->nombre  = nombre;
    this->precio  = precio;
}

// Getters
std::string Producto::getId()     const { return id; }
std::string Producto::getNombre() const { return nombre; }
float       Producto::getPrecio() const { return precio; }

// Operador +: suma los precios base de dos productos
float Producto::operator+(const Producto& otro) const {
    return this->precio + otro.precio;
}

// Operador ==: dos productos son iguales si comparten el mismo ID
bool Producto::operator==(const Producto& otro) const {
    return this->id == otro.id;
}

// Operador <<: imprime nombre y precio de cualquier producto
// (funciona con cualquier derivada sin conocer su tipo concreto)
std::ostream& operator<<(std::ostream& os, const Producto& p) {
    os << p.nombre << " - $" << p.precio;
    return os;
}
