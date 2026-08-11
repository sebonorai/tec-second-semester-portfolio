#include "Suscripcion.h"
#include <iostream>
#include <iomanip>

// Constructor: valida meses y descuento, delega precio al constructor base
Suscripcion::Suscripcion(std::string id, std::string nombre,
                         float precio, int meses, float descuento)
    : Producto(id, nombre, precio) {
    if (meses <= 0) {
        throw std::invalid_argument("Error: los meses deben ser mayor a cero.");
    }
    if (descuento < 0.0f || descuento >= 1.0f) {
        throw std::invalid_argument("Error: descuento debe estar entre 0.0 y 0.99.");
    }
    this->meses     = meses;
    this->descuento = descuento;
}

// Precio final: precio mensual * meses * factor de descuento
float Suscripcion::calcularPrecioFinal() {
    return precio * meses * (1.0f - descuento);
}

// Imprime todos los datos de la suscripcion
void Suscripcion::imprimirDatos() {
    std::cout << std::fixed << std::setprecision(2);
    std::cout << "[Suscripcion] " << getNombre()
              << " | Precio mensual: $" << getPrecio()
              << " | Meses: "     << meses
              << " | Descuento: " << (descuento * 100) << "%"
              << " | Total: $"    << calcularPrecioFinal()
              << std::endl;
}

// Costo neto sin descuento aplicado
float Suscripcion::getCosto() const {
    return precio * meses;
}

int   Suscripcion::getMeses()     const { return meses; }
float Suscripcion::getDescuento() const { return descuento; }
