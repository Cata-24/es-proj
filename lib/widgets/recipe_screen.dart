import 'package:app/widgets/common/throbber.dart';
import 'package:flutter/material.dart';
import 'package:app/databaseConnection/recipeLogic/import_recipe.dart';
import 'package:app/databaseConnection/recipeLogic/import_comment.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/widgets/add_recipe_screen.dart';
import 'package:app/user/user_session.dart';
import 'package:share_plus/share_plus.dart';
import 'package:app/services/dynamic_link_service.dart';
import 'package:app/databaseConnection/recipeLogic/recipe_storage_implementation.dart';

class RecipeDetailPage extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailPage({super.key, required this.recipe});

  @override
  _RecipeDetailPageState createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  String userIdCur = "";
  String userName = "";
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final authService = AuthService();
    if (authService.uid != null) userIdCur = authService.uid!;
    if (authService.name != null) userName = authService.name!;
  }

  void addComment(Comment comment) async {
    setState(() {
      widget.recipe.comments.insert(0, comment);
      _commentController.clear();
    });

    try {
      await RecipeStorageImplementation().addComment(widget.recipe.recipeId, comment);
    } catch (e) {
      print('Failed to add comment: $e');
    }
  }

  void removeComment(int index) async {
    Comment toRemove = widget.recipe.comments[index];

    setState(() {
      widget.recipe.comments.remove(toRemove);
      _commentController.clear();
    });

    try {
      await RecipeStorageImplementation().removeComment(widget.recipe.recipeId, index);
    } catch (e) {
      print('Failed to remove comment: $e');
    }
  }

  void setLike(bool value) async {
    setState(() {
      if (value) {
        widget.recipe.trackLikes.add(userIdCur);
      } else {
        widget.recipe.trackLikes.remove(userIdCur);
      }
    });

    try {
      if (value) {
        await RecipeStorageImplementation().addLike(widget.recipe.recipeId, userIdCur);
      } else {
        await RecipeStorageImplementation().removeLike(widget.recipe.recipeId, userIdCur);
      }
    } catch (e) {
      print('Failed to update like: $e');
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${timestamp.year}-${timestamp.month.toString().padLeft(
        2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';
  }

  void setSave(bool value) async {
    setState(() {
      if (value) {
        widget.recipe.saves.add(userIdCur);
      } else {
        widget.recipe.saves.remove(userIdCur);
      }
    });

    try {
      if (value) {
        await RecipeStorageImplementation().addSave(widget.recipe.recipeId, userIdCur);
      } else {
        await RecipeStorageImplementation().removeSave(widget.recipe.recipeId, userIdCur);
      }
    } catch (e) {
      print('Failed to update save: $e');
    }
  }

  void _editRecipe(Recipe recipe) async {
    final userId = UserSession().userId;

    if (userId == recipe.userId) {
      final updatedRecipe = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddRecipeScreen(recipe: recipe)),
      );

      if (updatedRecipe != null) {
        try {
          await RecipeStorageImplementation().updateRecipe(recipe.recipeId, updatedRecipe);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Recipe updated successfully")),
          );
          setState(() {});
          //refresh UI
        } catch (e) {
          print('Error updating recipe: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to update recipe")),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You cannot edit this recipe")),
      );
    }
  }

  Widget iconWithText2(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20),
        SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget iconWithText(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 4),
          Text(text),
        ],
      ),
    );
  }

  Widget buildCommentsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comments',
            style: TextStyle(fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green[900]),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 0).copyWith(
                left: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(30),
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Write a comment...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.green[900]),
                  onPressed: () {
                    final text = _commentController.text.trim();
                    if (text.isNotEmpty) {
                      final newComment = Comment(
                        userName: userName,
                        text: text,
                        timestamp: DateTime.now(),
                        userId: userIdCur,
                      );
                      addComment(newComment);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          widget.recipe.comments.isEmpty
              ? const Text("No comments yet.")
              : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.recipe.comments.length,
            itemBuilder: (context, index) {
              final comment = widget.recipe.comments[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.account_circle, size: 40.0,
                        color: Colors.green[900]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                comment.userName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatTimestamp(comment.timestamp),
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(comment.text),
                        ],
                      ),
                    ),
                    if (comment.userId == userIdCur ||
                        userIdCur == widget.recipe.userId)
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red[800]),
                        onPressed: () {
                          setState(() {
                            removeComment(index);
                          });
                        },
                        tooltip: 'Delete comment',
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }


  Widget buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Centered Recipe Name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60),
                child: Text(
                  widget.recipe.name,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),

              // Back Button on the left
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(Icons.keyboard_arrow_left, size: 40,
                      color: Colors.black),
                  onPressed: () => Navigator.pop(context, 'refresh'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Info icons (timer, servings, etc)
          Wrap(
            spacing: 16.0,
            runSpacing: 8.0,
            alignment: WrapAlignment.center,
            children: [
              iconWithText2(Icons.timer, '${widget.recipe.prepTime} min'),
              iconWithText2(Icons.people, widget.recipe.servings.toString()),
              iconWithText2(
                  Icons.star, 'Difficulty: ${widget.recipe.difficulty}/5'),
            ],
          ),

          const SizedBox(height: 2),

          // Action icons (edit, favorite, bookmark, share) under info icons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.recipe.userId == userIdCur)
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.black),
                  onPressed: () => _editRecipe(widget.recipe),
                ),

              IconButton(
                icon: Icon(
                    widget.recipe.trackLikes.contains(userIdCur)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: Colors.black
                ),
                onPressed: () =>
                    setLike(!widget.recipe.trackLikes.contains(userIdCur)),
              ),

              IconButton(
                icon: Icon(
                    widget.recipe.saves.contains(userIdCur)
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    color: Colors.black
                ),
                onPressed: () =>
                    setSave(!widget.recipe.saves.contains(userIdCur)),
              ),

              IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () async {
                    final link = await DynamicLinkService().createRecipeLink(
                        widget.recipe.recipeId);
                    SharePlus.instance.share(
                        ShareParams(text: 'Check out this recipe! $link'));
                  },
                  color: Colors.black
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget buildImage() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 180,
            maxWidth: 320,
          ),
          child: widget.recipe.imageUrl != null &&
              widget.recipe.imageUrl.isNotEmpty
              ? Image.network(
            widget.recipe.imageUrl,
            fit: BoxFit.cover, // cover, contain, or fitWidth depending on your design
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const SizedBox(
                height: 180,
                child: Center(child: Throbber()),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.broken_image,
                  size: 80, color: Colors.red);
            },
          )
              : Icon(Icons.food_bank, size: 80, color: Colors.green[900]),
        ),
      ),
    );
  }


  Widget buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ingredients
          Text(
            "Ingredients",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25,
              color: Colors.green[900],
            ),
          ),
          const SizedBox(height: 8),
          for (int i = 0; i < widget.recipe.ingredients.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      '${widget.recipe.ingredients[i]['id']}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.visible,
                      maxLines: null,
                    ),
                  ),
                  Text(
                    '${widget.recipe.ingredients[i]['quantity']}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          // Horizontal Divider
          Container(
            height: 1,
            color: Colors.green[900],
            margin: const EdgeInsets.symmetric(vertical: 25),
          ),

          // Preparation
          Text(
            "Preparation",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25,
              color: Colors.green[900],
            ),
          ),
          const SizedBox(height: 15),
          for (int i = 0; i < widget.recipe.steps.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 25),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 18, color: Colors.black),
                  children: [
                    TextSpan(
                      text: 'Step ${i + 1}\n',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: widget.recipe.steps[i]),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildHeader(context),
              buildImage(),

              buildContent(),

              buildCommentsSection(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
