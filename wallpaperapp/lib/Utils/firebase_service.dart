import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wallpaperapp/Models/wallpaper_model.dart';

import '../Models/user_model.dart';
import '../Views/login_page.dart';
import 'app_colors.dart';

class FireStoreService {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final CollectionReference wallpaperCollection = FirebaseFirestore.instance.collection('Collections');
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('Users');

  Future<void> signUpUser({required String name,required String email,required String phoneNumber,required String password}) async {
    try {

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      DocumentReference userDocRef = userCollection.doc(userCredential.user!.uid);
      await userDocRef.set({
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'profileImageUrl': 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png',
      });

    } catch (e) {
      log('Error signing up user: $e');
      rethrow;
    }
  }
  Future<void> loginUser({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      log('Error logging in user: $e');
      rethrow;
    }
  }
  Future<void> signOut() async {
    await _auth.signOut();
    Get.offAll(() => LoginPage(), transition: Transition.fadeIn, duration: const Duration(milliseconds: 500));
  }
  Future<void> resetPassword(String email) async {
    try {
      if(await isUserRegistered(email)){
        await _auth.sendPasswordResetEmail(email: email);
        Get.snackbar('Password Reset Email Sent to $email', 'Check your email for a password reset link', snackPosition: SnackPosition.BOTTOM, colorText: whiteColor);
      }else{
        throw "This Email is Not Registered with any Account";
      }
    }  on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        throw "The email doesn't seems to be right";
      } else {
        throw e.message ?? "An Error Occurred";
      }
    }catch (e){
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM, colorText: whiteColor, backgroundColor: Colors.redAccent);
      log(e.toString());
    }
  }
  Future<bool> isUserRegistered(String email) async {
    try {
      QuerySnapshot querySnapshot = await _fireStore
          .collection('Users')
          .where('email', isEqualTo: email)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      log('Error checking if user is registered: $e');
      return false;
    }
  }
  Future<void> updateProfileImage({
    required XFile profileImage,
  }) async {
    try {
      // Upload image to Firebase Storage
      File imageFile = File(profileImage.path);
      TaskSnapshot profileImageSnapShot = await _storage.ref().child('${_auth.currentUser!.uid}/profile_image').putFile(imageFile);

      // Get download URL
      String profileImageDownloadUrl = await profileImageSnapShot.ref.getDownloadURL();

      await userCollection.doc(_auth.currentUser?.uid).update({
        'profileImageUrl': profileImageDownloadUrl,
      });
    } catch (e) {
      log('Error uploading image: $e');
      rethrow;
    }
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String phoneNumber,
  }) async {
    try{
      User? user = _auth.currentUser;

      await userCollection.doc(user!.uid).update({
        'phoneNumber': phoneNumber,
        'name': name,
      });
    }catch(e){
      log("Error Updating Profile ${e.toString()}");
    }

  }

  Future<void> createCollection( String collectionName) async {
    try {
      DocumentReference collectionDocRef = userCollection.doc(_auth.currentUser!.uid).collection('user_collections').doc(collectionName);
      await collectionDocRef.set({
        'updated_at': DateTime.now(),
        'image_list': [],
      });
    } catch (e) {
      log('Error creating collection: $e');
      rethrow;
    }
  }

  Future<void> addToCollection({ required String collectionName, required PixabayImage image}) async {
    try {
      // Check if the collection already exists
      DocumentReference collectionDocRef = userCollection.doc(_auth.currentUser!.uid).collection('user_collections').doc(collectionName);
      DocumentSnapshot collectionDoc = await collectionDocRef.get();

      List<dynamic> imageList = [];
      if (collectionDoc.exists) {
        // If the collection exists, get the current image list
        Map<String, dynamic> data = collectionDoc.data() as Map<String, dynamic>;
        imageList = data['image_list'] ?? [];

        // Check if the image is already in the collection
        bool imageExists = imageList.any((element) => element['id'] == image.id);
        if (imageExists) {
          throw 'Image already exists in the collection';
        }
      }

      // Add the new image to the list
      imageList.add(image.toJson());

      // Update the collection document with the new image list
      await collectionDocRef.set({
        'updated_at': DateTime.now(),
        'image_list': imageList,
      });
    } catch (e) {
      log('Error adding image to collection: $e');
      rethrow;
    }
  }


  Future<bool> hasCollections() async {
    try {
      QuerySnapshot querySnapshot = await userCollection.doc(_auth.currentUser!.uid).collection('user_collections').get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      log('Error checking if user has collections: $e');
      return false;
    }
  }

  Future<List<String>> getCollectionNames() async {
    try {
      QuerySnapshot querySnapshot = await userCollection.doc(_auth.currentUser!.uid).collection('user_collections').get();
      List<String> collectionNames = querySnapshot.docs.map((doc) => doc.id).toList();
      return collectionNames;
    } catch (e) {
      log('Error getting collection names: $e');
      return [];
    }
  }

  Future<UserModel?> getUserDataFromFirebase() async {
    try {
      DocumentSnapshot documentSnapshot = await _fireStore
          .collection('Users')
          .doc(_auth.currentUser!.uid)
          .get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> userData = documentSnapshot.data() as Map<String, dynamic>;
        return UserModel.fromJson(userData);
      } else {
        return null;
      }
    } catch (e) {
      log('Error getting user data: $e');
      return null;
    }
  }

  Future<void> deleteCollection(String collectionName) async {
    try {
      await userCollection.doc(_auth.currentUser!.uid).collection('user_collections').doc(collectionName).delete();
    } catch (e) {
      log('Error deleting collection: $e');
      rethrow;
    }
  }

  Future<List<PixabayImage>> getImagesFromCollection(String collectionName) async {
    try {
      List<PixabayImage> images = [];
      DocumentSnapshot<Map<String, dynamic>> querySnapshot = await userCollection.doc(_auth.currentUser!.uid).collection('user_collections').doc(collectionName).get();

      List<dynamic> imageList = querySnapshot.data()?['image_list'] ?? [];
      for (var imageData in imageList) {
        PixabayImage image = PixabayImage.fromJson(imageData);
        images.add(image);
      }

      return images;
    } catch (e) {
      log('Error getting images from collection: $e');
      return [];
    }
  }




}