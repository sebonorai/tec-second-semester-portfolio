#include <iostream>
#include <vector>
#include <iomanip>
#include "Producto.h"
#include "ProductoFisico.h"
#include "ProductoDigital.h"
#include "Suscripcion.h"

// Separador visual para consola
void separador(const std::string& titulo) {
    std::cout << "\n========================================\n";
    std::cout << "  " << titulo << "\n";
    std::cout << "========================================\n";
}

int main() {

    std::cout << std::fixed << std::setprecision(2);

    // ─── CASO 1: Crear objetos e imprimir datos ──────────────────────────────
    separador("CASO 1 - Crear objetos e imprimirDatos()");

    ProductoFisico laptop("PF001", "Laptop Dell XPS", 999.99f, 1.5f, 10);
    ProductoFisico teclado("PF002", "Teclado Mecanico", 149.99f, 0.8f, 25);
    ProductoDigital adobe("PD001", "Adobe Photoshop", 599.99f, 2048.0f, "Anual");
    ProductoDigital vscode("PD002", "VS Code Pro", 49.99f, 120.0f, "Perpetua");
    Suscripcion spotify("S001", "Spotify Premium", 9.99f, 12, 0.15f);
    Suscripcion netflix("S002", "Netflix Standard", 14.99f, 6, 0.10f);

    laptop.imprimirDatos();
    teclado.imprimirDatos();
    adobe.imprimirDatos();
    vscode.imprimirDatos();
    spotify.imprimirDatos();
    netflix.imprimirDatos();

    // ─── CASO 2: Calcular precios finales (sobreescritura) ───────────────────
    separador("CASO 2 - calcularPrecioFinal() sobreescrito");

    std::cout << "Laptop Dell XPS:\n";
    std::cout << "  Precio base:  $" << laptop.getPrecio()          << "\n";
    std::cout << "  Envio (1.5kg * $5): $" << 1.5f * 5.0f          << "\n";
    std::cout << "  Precio final: $" << laptop.calcularPrecioFinal() << "\n\n";

    std::cout << "Adobe Photoshop (>1GB, recargo 10%):\n";
    std::cout << "  Precio base:  $" << adobe.getPrecio()           << "\n";
    std::cout << "  Precio final: $" << adobe.calcularPrecioFinal()  << "\n\n";

    std::cout << "Spotify Premium (12 meses, 15% dto.):\n";
    std::cout << "  Precio mensual: $" << spotify.getPrecio()           << "\n";
    std::cout << "  Sin descuento:  $" << spotify.getPrecio() * 12      << "\n";
    std::cout << "  Precio final:   $" << spotify.calcularPrecioFinal() << "\n";

    // ─── CASO 3: Polimorfismo con vector de Producto* ────────────────────────
    separador("CASO 3 - Polimorfismo (vector de Producto*)");

    std::vector<Producto*> catalogo;
    catalogo.push_back(&laptop);
    catalogo.push_back(&adobe);
    catalogo.push_back(&spotify);
    catalogo.push_back(&teclado);
    catalogo.push_back(&vscode);
    catalogo.push_back(&netflix);

    std::cout << "Catalogo completo (" << catalogo.size() << " productos):\n\n";
    for (Producto* p : catalogo) {
        p->imprimirDatos(); // polimorfismo: version correcta segun tipo real
    }

    // ─── CASO 4: Sobrecarga de operadores ────────────────────────────────────
    separador("CASO 4 - Sobrecarga de operadores (+, ==, <<)");

    // operator+: suma precios base
    float sumaLaptopAdobe = laptop + adobe;
    std::cout << "operator+ | Laptop + Adobe:    $" << sumaLaptopAdobe << "\n";

    float sumaSpotifyNetflix = spotify + netflix;
    std::cout << "operator+ | Spotify + Netflix: $" << sumaSpotifyNetflix << "\n\n";

    // operator==: comparacion por ID
    ProductoFisico copia("PF001", "Copia Laptop", 1.0f, 0.1f, 1);
    std::cout << "operator== | laptop == copia (mismo ID PF001): "
              << (laptop == copia ? "true  -> Son el mismo producto" : "false") << "\n";
    std::cout << "operator== | laptop == teclado (IDs distintos): "
              << (laptop == teclado ? "true" : "false -> Son distintos") << "\n\n";

    // operator<<: imprime nombre y precio base de cualquier Producto*
    std::cout << "operator<< | " << laptop  << "\n";
    std::cout << "operator<< | " << adobe   << "\n";
    std::cout << "operator<< | " << spotify << "\n\n";

    // ─── CASO EXTRA: Excepcion por precio negativo ───────────────────────────
    separador("CASO EXTRA - Excepcion por precio negativo (punto h)");

    try {
        ProductoFisico invalido("ERR001", "Producto Invalido", -100.0f, 1.0f, 5);
    } catch (const std::invalid_argument& e) {
        std::cout << "Excepcion capturada: " << e.what() << "\n";
        std::cout << "El objeto no fue creado. Programa continua con normalidad.\n";
    }

    separador("FIN DEL PROGRAMA");
    return 0;
}
