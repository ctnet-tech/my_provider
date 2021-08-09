import 'package:flutter/material.dart';

import 'product_data.dart';

const loadingText = 'LOADING';

getProductBuidler(fetchState)
{
  if (fetchState.loading == true)
  {
    return Text(loadingText, textDirection: TextDirection.ltr);
  }

  if (fetchState.response != null)
  {
    return Text(fetchState.response!.name!, textDirection: TextDirection.ltr);
  }

  return Text("NULL", textDirection: TextDirection.rtl);
}

deleteProducrtBuidler(fetchState)
{
  if (fetchState.loading == true)
  {
    return Text(loadingText, textDirection: TextDirection.ltr);
  }

  if (fetchState.response != null)
  {
    return Text(fetchState.response!.name!, textDirection: TextDirection.ltr);
  }

  return MaterialApp(
    home: Scaffold(
      body: ElevatedButton(
        child: Text("Delete", textDirection: TextDirection.ltr),
        onPressed: ()
        => fetchState.fetch(null),
      ),
    ),
  );
}

createProductBuilder(fetchState)
{
  if (fetchState.loading == true)
  {
    return Text(loadingText, textDirection: TextDirection.ltr);
  }

  if (fetchState.response != null)
  {
    return Text(fetchState.response!.name!, textDirection: TextDirection.ltr);
  }

  return MaterialApp(
    home: Scaffold(
      body: ElevatedButton(
        child: Text("Create product", textDirection: TextDirection.ltr),
        onPressed: ()
        => fetchState.fetch(params),
      ),
    ),
  );
}

infinityScrollProductBuilder(fetchState)
{
  if (fetchState.loading == true)
  {
    return Text(loadingText, textDirection: TextDirection.ltr);
  }

  if (fetchState.response != null)
  {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            ElevatedButton(
              child: Text("load more product", textDirection: TextDirection.ltr),
              onPressed: ()
              => fetchState.fetch(ProductFetchParams(page: fetchState.page+1,productId: params.productId,body: params.body)),
            ),
          ],
        ),
      ),
    );
  }
  return  Text("NULL", textDirection: TextDirection.ltr);
}

pagingProductBuilder(fetchState)
{
  if (fetchState.loading == true)
  {
    return Text(loadingText, textDirection: TextDirection.ltr);
  }

  if (fetchState.response != null)
  {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            ElevatedButton(
              child: Text("Page 1", textDirection: TextDirection.ltr),
              onPressed: ()
              => fetchState.fetch(ProductFetchParams(page: 1,productId: params.productId,body: params.body)),
            ),
            ElevatedButton(
              child: Text("Page 2", textDirection: TextDirection.ltr),
              onPressed: ()
              => fetchState.fetch(ProductFetchParams(page: 2,productId: params.productId,body: params.body)),
            ),
          ],
        ),
      ),
    );
  }
  return  Text("NULL", textDirection: TextDirection.ltr);
}