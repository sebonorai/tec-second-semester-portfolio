# Marketplace — Object-Oriented Product Catalog in C++

Integrative project for TC1030 (Object-Oriented Programming), Tecnologico de Monterrey.

## The problem

A marketplace sells things that behave differently but need to be handled uniformly. A physical laptop has weight and stock, and shipping is charged by the kilogram. A software license has a file size and a license term, and large downloads carry a surcharge. A subscription is priced monthly and gets cheaper the longer you commit.

Three different pricing rules, three different sets of attributes — but the catalog should be able to hold all of them together and ask each one the same question: *what do you cost?*

That's the design problem this project solves.

## The design

`Producto` is an abstract base class. It owns what every product has in common — an ID, a name, a base price — and declares what every product must be able to do, without saying how:

```cpp
virtual float calcularPrecioFinal() = 0;
virtual void  imprimirDatos()       = 0;
virtual float getCosto()      const = 0;
```

Three classes derive from it, each implementing those methods with its own rule:

| Class | Extra state | Pricing rule |
|---|---|---|
| `ProductoFisico` | weight (kg), stock | base price + weight × $5 shipping |
| `ProductoDigital` | size (MB), license type | base price + 10% surcharge if over 1 GB |
| `Suscripcion` | months, discount rate | monthly price × months, minus the commitment discount |

Because they share the interface, a `std::vector<Producto*>` can hold all six catalog items at once, and calling `imprimirDatos()` on each pointer dispatches to the right implementation at runtime.

### Design decisions worth noting

- **`precio` is `protected`, not `private`.** Derived classes compute their final price from the base price, so they need direct access. `id` and `nombre` stay private — nothing downstream needs to touch them.
- **The destructor is virtual.** Required in any polymorphic base class: deleting a derived object through a base pointer with a non-virtual destructor is undefined behavior.
- **`operator<<` is a friend function.** It needs to read private members, and as a free function it keeps the natural `stream << object` argument order.

### Operator overloading

- `operator+` — sums the base prices of two products, whatever their concrete types
- `operator==` — compares by ID, so two objects representing the same catalog entry compare equal even if their other fields differ
- `operator<<` — prints any `Producto` to a stream

### Error handling

The constructor rejects a negative price by throwing `std::invalid_argument`. The object is never constructed and the caller can recover:

```cpp
try {
    ProductoFisico invalido("ERR001", "Producto Invalido", -100.0f, 1.0f, 5);
} catch (const std::invalid_argument& e) {
    std::cout << "Excepcion capturada: " << e.what() << "\n";
}
```

## Files

```
main.cpp             Driver — runs five demonstration cases
Producto.h/.cpp      Abstract base class
ProductoFisico.h/.cpp    Physical goods
ProductoDigital.h/.cpp   Digital licenses
Suscripcion.h/.cpp       Subscriptions
uml-diagram.png      Class diagram
```

## Build and run

```bash
g++ -std=c++17 -Wall -o marketplace main.cpp Producto.cpp ProductoFisico.cpp ProductoDigital.cpp Suscripcion.cpp
./marketplace
```

`main.cpp` walks through five cases: object construction, overridden pricing, polymorphic dispatch over a mixed catalog, each overloaded operator, and the exception path.

## What I'd change

The catalog holds raw `Producto*` pointing at stack objects. In anything beyond a course demo those should be `std::unique_ptr<Producto>` in a container that owns them — which is exactly why the virtual destructor matters.
