import 'package:flutter/material.dart';
import 'package:my_provider/fetch.dart';

import 'product.dart';
import 'product_data.dart';

const loadingText = 'LOADING';
const deleteText = 'DELETE';
const deletedText = 'DELETED';

Widget getProductBuidler(FetchState<Product> fetchState) {
  if (fetchState.loading == true) {
    return Text(loadingText, textDirection: TextDirection.ltr);
  }

  if (fetchState.response == null) {
    return Text("NULL", textDirection: TextDirection.rtl);
  }

  return Text(fetchState.response!.name!, textDirection: TextDirection.ltr);
}

Widget deleteProducrtBuidler(FetchState<Product> fetchState) {
  if (fetchState.loading == true) {
    return Text(loadingText, textDirection: TextDirection.ltr);
  }

  if (fetchState.response != null) {
    return Text(fetchState.response!.name!, textDirection: TextDirection.ltr);
  }

  return MaterialApp(
    home: Scaffold(
      body: ElevatedButton(
        child: Text(deleteText, textDirection: TextDirection.ltr),
        onPressed: () => fetchState.fetch(null),
      ),
    ),
  );
}

Widget createProductBuilder(FetchState<Product> fetchState) {
  if (fetchState.loading == true) {
    return Text(loadingText, textDirection: TextDirection.ltr);
  }

  if (fetchState.response != null) {
    return Text(fetchState.response!.name!, textDirection: TextDirection.ltr);
  }

  return MaterialApp(
    home: Scaffold(
      body: ElevatedButton(
        child: Text("Create product", textDirection: TextDirection.ltr),
        onPressed: () => fetchState.fetch(params),
      ),
    ),
  );
}
