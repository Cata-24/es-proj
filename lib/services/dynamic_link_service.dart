import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class DynamicLinkService {
  Future<Uri> createRecipeLink(String recipeId) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://mypantryapp.page.link',
      link: Uri.parse('https://mypantryapp.page.link/recipe?id=$recipeId'),

      androidParameters: AndroidParameters(
        packageName: 'com.example.app',
        minimumVersion: 1,
      ),

      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'Check out this recipe!',
        description: 'Tap to see this delicious recipe.',
      ),
    );

    final ShortDynamicLink shortLink = await FirebaseDynamicLinks.instance.buildShortLink(parameters);
    return shortLink.shortUrl;
  }
}
