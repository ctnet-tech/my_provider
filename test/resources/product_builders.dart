import 'package:flutter/material.dart';

import 'product_data.dart';

const loadingText = 'LOADING';

getProductBuidler(fetchState) {
  if (fetchState.loading == true) {
    return Text(loadingText, textDirection: TextDirection.ltr);
  }

  if (fetchState.response != null) {
    return Text(fetchState.response!.name!, textDirection: TextDirection.ltr);
  }

  return Text("NULL", textDirection: TextDirection.rtl);
}

deleteProducrtBuidler(fetchState) {
  if (fetchState.loading == true) {
    return Text(loadingText, textDirection: TextDirection.ltr);
  }

  if (fetchState.response != null) {
    return Text(fetchState.response!.name!, textDirection: TextDirection.ltr);
  }

  return MaterialApp(
    home: Scaffold(
      body: ElevatedButton(
        child: Text("Delete", textDirection: TextDirection.ltr),
        onPressed: () => fetchState.fetch(null),
      ),
    ),
  );
}

createProductBuilder(fetchState) {
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
