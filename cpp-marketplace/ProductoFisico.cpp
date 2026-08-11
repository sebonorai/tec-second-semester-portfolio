#include "ProductoFisico.h"
#include <iostream>
#include <iomanip>

// Constructor: valida stock y delega precio al constructor base
ProductoFisico::ProductoFisico(std::string id, std::string nombre,
                               float precio, float peso, int stock)
    : Producto(id, nombre, precio) {
    if (stock < 0) {
        throw std::invalid_argument("Error: el stock no puede ser negativo.");
    }
    if (peso <= 0) {
        throw std::invalid_argument("Error: el peso debe ser mayor a cero.");
    }
    this->peso  = peso;
    this->stock = stock;
}

// Precio final: agrega costo de envio basado en peso ($5 por kg)
float ProductoFisico::calcularPrecioFinal() {
    float costoEnvio = peso * 5.0f;
    return precio + costoEnvio;
}

// Imprime todos los datos del producto fisico
void ProductoFisico::imprimirDatos() {
    std::cout << std::fixed << std::setprecision(2);
    std::cout << "[ProductoFisico] " << getNombre()
              << " | Precio base: $" << getPrecio()
              << " | Precio final: $" << calcularPrecioFinal()
              << " | Peso: "   << peso  << "kg"
              << " | Stock: "  << stock << " uds."
              << std::endl;
}

// Costo neto (sin envio) - equivalente al precio base
float ProductoFisico::getCosto() const {
    return precio;
}

float ProductoFisico::getPeso()  const { return peso; }
int   ProductoFisico::getStock() const { return stock; }
