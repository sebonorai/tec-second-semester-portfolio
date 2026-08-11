#ifndef SUSCRIPCION_H
#define SUSCRIPCION_H

#include "Producto.h"
#include <stdexcept>

// Clase derivada: representa una suscripcion de servicio por meses
// El precio final se calcula como: precio * meses * (1 - descuento)
class Suscripcion : public Producto {

private:
    int   meses;      // duracion de la suscripcion en meses
    float descuento;  // porcentaje de descuento en decimal (ej. 0.15 = 15%)

public:
    Suscripcion(std::string id, std::string nombre, float precio,
                int meses, float descuento);

    // Sobreescritura de metodos virtuales puros
    float calcularPrecioFinal() override;
    void  imprimirDatos()       override;
    float getCosto()      const override;

    // Getters propios
    int   getMeses()     const;
    float getDescuento() const;
};

#endif
