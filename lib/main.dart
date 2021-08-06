
import 'dart:math';
import 'package:hexcolor/hexcolor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Represenst a Cart Item. Has <int>`id`, <String>`name`, <int>`quantity`
class CartItem {
  CartItem({required this.id, required this.name, required this.quantity});

  final int id;
  final String name;
  int quantity;


}

/// Manages a cart. Implements ChangeNotifier
class CartState with ChangeNotifier {
  List<CartItem> _products = [];

  CartState();

  /// The number of individual items in the cart. That is, all cart items' quantities.
  int get totalCartItems => _products.length;// TODO: return actual cart volume.

  /// The list of CartItems in the cart
  List<CartItem> get products => List.of(_products);

  /// Clears the cart. Notifies any consumers.
  void clearCart() {
    _products.clear();
    notifyListeners();
  }

  /// Adds a new CartItem to the cart. Notifies any consumers.
  void addToCart({required CartItem item}) {
    _products.add(item);
    notifyListeners();
  }

  /// Updates the quantity of the Cart item with this id. Notifies any consumers.
  void updateQuantity({required int id, required int newQty}) {
    if(newQty > 0) {
      _products
          .firstWhere((element) => element.id == id)
          .quantity = newQty;
      notifyListeners();
    }
    else{
      _products.removeWhere((element) => element.id == id);
      notifyListeners();
    }

  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CartState(),
      child: MyCartApp(),
    ),
  );
}

class MyCartApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
        fontFamily: 'Railway',
        textTheme: const TextTheme(
        bodyText1: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),

    ),),
      home: Scaffold(
        backgroundColor: HexColor('C9C9C9'),
        body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ListOfCartItems(),
              CartSummary(),
              CartControls(),
            ],
          ),
        ),
      ),
    );
  }
}

class CartControls extends StatelessWidget {
  /// Handler for Add Item pressed
  void _addItemPressed(BuildContext context) {
    /// mostly unique cartItemId.
    /// don't change this; not important for this test
    int nextCartItemId = Random().nextInt(10000);
    String nextCartItemName = 'A cart item';
    int nextCartItemQuantity = 1;

    CartItem
        item = new CartItem(id: nextCartItemId, name: nextCartItemName, quantity: nextCartItemQuantity); // Actually use the CartItem constructor to assign id, name and quantity

    // TODO: Get the cart current state through Provider. Add this cart item to cart.
    Provider.of<CartState>(context, listen: false).addToCart(item: item);
  }

  /// Handle clear cart pressed. Should clear the cart
  void _clearCartPressed(BuildContext context) {
    Provider.of<CartState>(context, listen: false).clearCart();
  }

  @override
  Widget build(BuildContext context) {
    final Widget addCartItemWidget = TextButton(
      child: Text('Add Item', style: Theme.of(context).textTheme.bodyText1,),
      onPressed: () => _addItemPressed(context),
      style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(HexColor('#3EB595')),
      overlayColor: MaterialStateProperty.all<Color>(HexColor('#696969')))
    );

    final Widget clearCartWidget = TextButton(
      child: Text('Clear Cart', style: Theme.of(context).textTheme.bodyText1,),
      onPressed: () {
        _clearCartPressed(context);
      },
      style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(HexColor('#3EB595')),
            overlayColor: MaterialStateProperty.all<Color>(HexColor('#696969')))

    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        addCartItemWidget,
        clearCartWidget,
      ],
    );
  }
}

class ListOfCartItems extends StatelessWidget {
  /// Handles adding 1 to the current cart item quantity.
  void _incrementQuantity(context, int id, int delta) {
    Provider.of<CartState>(context, listen: false).updateQuantity(id: id, newQty: delta);
  }

  /// Handles removing 1 to the current cart item quantity.
  /// Don't forget: we can't have negative numbers of an item in the cart
  void _decrementQuantity(context, int id, int delta) {
    Provider.of<CartState>(context, listen: false).updateQuantity(id: id, newQty: delta);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartState>(
        builder: (BuildContext context, CartState cart, Widget? child) {
      if (cart.totalCartItems == 0) {
        // TODO: return a Widget that tells us there are no items in the cart
        return Column(
          children: [
            Text("No Item in the cart", style: Theme.of(context).textTheme.headline6)
          ],
        );
      }

      return Column(children: [
        ...cart.products.map(
          (c) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // TODO: Widget for the line item name AND current quantity, eg "Item name x 4".
                Container(
                  alignment: Alignment.center,
                  color: Colors.grey,
                  child: Text("${c.name} x ${c.quantity}", style: Theme.of(context).textTheme.headline6,),
                  ),
                //  Current quantity should update whenever a change occurs.
                // TODO: Button to handle incrementing cart quantity. Handler is above.
                IconButton(onPressed: ()=> _incrementQuantity(context, c.id , c.quantity + 1), icon: new Icon(Icons.add),
                  splashColor: Colors.white, splashRadius: 20,),
                // TODO: Button to handle decrementing cart quantity. Handler is above.
                IconButton(onPressed: ()=> _decrementQuantity(context, c.id, c.quantity - 1), icon: new Icon(Icons.remove),
                  splashColor: Colors.white, splashRadius: 20,),
              ],
            ),
          ),
        ),
      ]);
    });
  }
}

class CartSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Consumer<CartState>(
      builder: (BuildContext context, CartState cart, Widget? child) {
        return Text("Total items: ${Provider.of<CartState>(context,listen:true).totalCartItems}");
      },
    );
  }
}
