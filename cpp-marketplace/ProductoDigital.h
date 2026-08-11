#ifndef PRODUCTODIGITAL_H
#define PRODUCTODIGITAL_H

#include "Producto.h"
#include <stdexcept>

// Clase derivada: representa un producto de descarga digital
// No tiene peso ni costo de envio; aplica recargo por tamano si >1GB
class ProductoDigital : public Producto {

private:
    float       tamanoMB;  // tamano del archivo en megabytes
    std::string licencia;  // tipo de licencia (Anual, Perpetua, Trial)

public:
    ProductoDigital(std::string id, std::string nombre, float precio,
                    float tamanoMB, std::string licencia);

    // Sobreescritura de metodos virtuales puros
    float calcularPrecioFinal() override;
    void  imprimirDatos()       override;
    float getCosto()      const override;

    // Getters propios
    float       getTamano()   const;
    std::string getLicencia() const;
};

#endif
