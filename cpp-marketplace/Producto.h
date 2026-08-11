#ifndef PRODUCTO_H
#define PRODUCTO_H

#include <string>
#include <iostream>
#include <stdexcept>

// Clase abstracta base del sistema Marketplace
// Define la interfaz comun para todos los tipos de producto
class Producto {

private:
    std::string id;
    std::string nombre;

protected:
    float precio; // Accesible por clases derivadas para calcular precio final

public:
    // Constructor
    Producto(std::string id, std::string nombre, float precio);

    // Destructor virtual (obligatorio en clases base polimorficas)
    virtual ~Producto() {}

    // Metodos virtuales puros (obligan implementacion en cada derivada)
    virtual float calcularPrecioFinal() = 0;
    virtual void  imprimirDatos()       = 0;
    virtual float getCosto()      const = 0;

    // Getters
    std::string getId()     const;
    std::string getNombre() const;
    float       getPrecio() const;

    // Sobrecarga de operadores
    float operator+(const Producto& otro) const;        // Suma de precios base
    bool  operator==(const Producto& otro) const;       // Compara por ID

    // operator<< como funcion amiga para acceder a atributos privados
    friend std::ostream& operator<<(std::ostream& os, const Producto& p);
};

#endif
