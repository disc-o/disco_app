import 'package:stencil/stencil.dart' as stencil;
import 'const.dart';

class GrantAccessPage {
  final String client_id;
  final String redirect_url;

  GrantAccessPage(this.client_id, this.redirect_url);
}

class GrantAccessPageComponent extends stencil.Component {
  final GrantAccessPage page;
  GrantAccessPageComponent(this.page);
  @override
  String render() {
    return htmlTemplate(
        body: '''
        <h3>${page.client_id} is requesting access to your account:</h3>
        <p>Sign in to grant ${page.client_id} access.</p>
        <form action="/signin" method="post">
          <p>Username:</p>
          <input type="text" name="username">
          <p>Password:</p>
          <input type="Password" name="password">
          <input type="hidden" name="client_id" value="${page.client_id}">
          <input type="hidden" name="redirect_uri" value="${page.redirect_url}">
          <input type="hidden" name="grant_type" value="asd">
          <p>
            <input type="submit" value="Sign in">
          </p>
        </form>
        <form>
          <select name="single">
            <option>Single</option>
            <option>Single2</option>
          </select>
        
          <br>
          <select name="multiple" multiple="multiple">
            <option selected="selected">Multiple</option>
            <option>Multiple2</option>
            <option selected="selected">Multiple3</option>
          </select>
        
          <br>
          <input type="checkbox" name="check" value="check1" id="ch1">
          <label for="ch1">check1</label>
          <input type="checkbox" name="check" value="check2" checked="checked" id="ch2">
          <label for="ch2">check2</label>
        
          <br>
          <input type="radio" name="radio" value="radio1" checked="checked" id="r1">
          <label for="r1">radio1</label>
          <input type="radio" name="radio" value="radio2" id="r2">
          <label for="r2">radio2</label>
        </form>
        
        <p><tt id="results"></tt></p>
        
        <script>
          function showValues() {
            var str = \$( "form" ).serialize();
            \$( "#results" ).text( str );
          }
          \$( "input[type='checkbox'], input[type='radio']" ).on( "click", showValues );
          \$( "select" ).on( "change", showValues );
          showValues();
        </script>
      ''',
        title: 'Sign in',
        head: '<script src="https://code.jquery.com/jquery-1.10.2.js"></script>');
  }
}
