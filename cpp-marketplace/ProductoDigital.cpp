#include "ProductoDigital.h"
#include <iostream>
#include <iomanip>

// Constructor: valida tamano y delega precio al constructor base
ProductoDigital::ProductoDigital(std::string id, std::string nombre,
                                 float precio, float tamanoMB,
                                 std::string licencia)
    : Producto(id, nombre, precio) {
    if (tamanoMB <= 0) {
        throw std::invalid_argument("Error: el tamano debe ser mayor a cero.");
    }
    if (licencia.empty()) {
        throw std::invalid_argument("Error: la licencia no puede estar vacia.");
    }
    this->tamanoMB = tamanoMB;
    this->licencia = licencia;
}

// Precio final: recargo del 10% si el archivo supera 1 GB (1024 MB)
float ProductoDigital::calcularPrecioFinal() {
    if (tamanoMB > 1024.0f) {
        return precio * 1.10f;
    }
    return precio;
}

// Imprime todos los datos del producto digital
void ProductoDigital::imprimirDatos() {
    std::cout << std::fixed << std::setprecision(2);
    std::cout << "[ProductoDigital] " << getNombre()
              << " | Precio base: $" << getPrecio()
              << " | Precio final: $" << calcularPrecioFinal()
              << " | Tamano: "   << tamanoMB << "MB"
              << " | Licencia: " << licencia
              << std::endl;
}

// Costo neto sin recargo
float ProductoDigital::getCosto() const {
    return precio;
}

float       ProductoDigital::getTamano()   const { return tamanoMB; }
std::string ProductoDigital::getLicencia() const { return licencia; }
