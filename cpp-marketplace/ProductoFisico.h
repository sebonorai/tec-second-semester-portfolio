#ifndef PRODUCTOFISICO_H
#define PRODUCTOFISICO_H

#include "Producto.h"
#include <stdexcept>

// Clase derivada: representa un producto con existencia fisica
// Hereda publicamente de Producto
class ProductoFisico : public Producto {

private:
    float peso;   // en kilogramos
    int   stock;  // unidades disponibles

public:
    ProductoFisico(std::string id, std::string nombre, float precio,
                   float peso, int stock);

    // Sobreescritura de metodos virtuales puros
    float calcularPrecioFinal() override;
    void  imprimirDatos()       override;
    float getCosto()      const override;

    // Getters propios
    float getPeso()  const;
    int   getStock() const;
};

#endif
