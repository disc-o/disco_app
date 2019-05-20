import 'package:stencil/stencil.dart' as stencil;
import 'const.dart';

class QueryResponsePage {
  final String response_type;
  final String client_id;
  final String redirect_url;
  QueryResponsePage(this.response_type, this.client_id, this.redirect_url);
}

class QueryResponsePageComponent extends stencil.Component {
  final QueryResponsePage page;
  QueryResponsePageComponent(this.page);
  @override
  String render() {
    return htmlTemplate(body: '''
      <h1>Your query is:</h1>
      <p>response_type: ${page.response_type}</p>
      <p>client_id: ${page.client_id}</p>
      <p>redirect_url: ${page.redirect_url}</p>
      ''', title: 'Display query params');
  }
}
