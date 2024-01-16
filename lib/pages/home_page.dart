import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:like_app/helper/helper_function.dart';
import 'package:like_app/pages/login_page.dart';
import 'package:like_app/pages/pageInPage/home.dart';
import 'package:like_app/pages/pageInPage/likes.dart';
import 'package:like_app/pages/pageInPage/postPage/post.dart';
import 'package:like_app/pages/pageInPage/profilePage/profilePage.dart';
import 'package:like_app/pages/pageInPage/search.dart';
import 'package:like_app/services/auth_service.dart';
import 'package:like_app/services/userService.dart';
import 'package:like_app/shared/constants.dart';
import 'package:like_app/widgets/widgets.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:image/image.dart' as img;

class HomePage extends StatefulWidget {

  final int pageIndex;

  const HomePage({super.key, required this.pageIndex});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  AuthServie authServie = AuthServie();
  final picker = ImagePicker();
  var logger = Logger();

  String userName = "";
  String email = "";

  bool isErrorOccurred = false;
  bool isAudioSessionLoading = true;

  bool isImagesLoading = false;

  List<File> selectedImages = [];

  int selectedIndex = 0;

  @override
  void initState() {

    // selectedIndex = widget.pageIndex;

    // setState(() {
    //   if (this.mounted) {
    //     _widgetOptions[0] =  Home(scrollController: homeScrollController);
    //     _widgetOptions[1] =  LikesRanking(scrollController: likeScrollController);
    //     _widgetOptions[3] = ProfilePage(scrollController: profileScrollController);
    //   }
    // });

    super.initState();

    selectedIndex = widget.pageIndex;

    setState(() {
      if (this.mounted) {
        _widgetOptions[0] =  Home(scrollController: homeScrollController);
        _widgetOptions[1] =  LikesRanking(scrollController: likeScrollController);
        _widgetOptions[3] = ProfilePage(scrollController: profileScrollController);
      }
    });

    gettingUserData();

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      DatabaseService userService = new DatabaseService();
      userService.updateMessagingToken(newToken);
    });     // firebase notification token

  }

  gettingUserData() async {

    try {
      await HelperFunctions.getUserEmailFromSF().then((value) => {
        setState(() {
          email = value!;
        })
      });

      await HelperFunctions.getUserNameFromSF().then((value) => {
        setState(() {
          userName = value!;
        })
      });

    } catch(e) {
      if (this.mounted) {setState(() {
        isErrorOccurred = true;
      });}
      logger.log(Level.error, "error occurred while getting user data\nerror: " + e.toString());
    }
  }

  final PageController _pageController = PageController();
  final ScrollController homeScrollController = ScrollController();
  final ScrollController profileScrollController = ScrollController();
  final ScrollController likeScrollController = ScrollController();

  final _widgetOptions = <Widget>[
    Home(scrollController: ScrollController()),
    LikesRanking(scrollController: ScrollController()),
    Post(images: []),
    ProfilePage(scrollController: ScrollController())
  ];

  @override
  void dispose() {
    _pageController.dispose();
    homeScrollController.dispose();
    profileScrollController.dispose();
    likeScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    double toolbarHeight = MediaQuery.of(context).size.height * 0.08;
    double sizedBox;
    double iconSize = MediaQuery.of(context).size.height * 0.023;

    bool isTablet;

    if(Device.get().isTablet) {
      isTablet = true;
      sizedBox = MediaQuery.of(context).size.height * 0.00;
    }
    else {
      isTablet = false;
      sizedBox = MediaQuery.of(context).size.height * 0.047;
    }
    
    try {
      return AbsorbPointer(
      absorbing: isImagesLoading,
      child:
        WillPopScope(
        onWillPop: () async {
          return Future.value(false);
        },
        child: isErrorOccurred ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(onPressed: () {
                
                setState(() {
                  isErrorOccurred = false;
                  selectedIndex = 0;
                });
                gettingUserData();
                
              }, icon: Icon(Icons.refresh, size: MediaQuery.of(context).size.width * 0.08, color: Colors.blueGrey,),),
              Text("failed to load", style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.blueGrey))
            ],
          )
      ) :
       Scaffold(
        resizeToAvoidBottomInset: false,
          appBar: AppBar(
          iconTheme: IconThemeData(color: Constants().iconColor),
          toolbarHeight: toolbarHeight,
          
          actions: [
            IconButton(onPressed: (){
              try {
                nextScreen(context, Search(searchName: "",));
              } catch(e) {
                if (this.mounted) {
                  setState(() {
                    isErrorOccurred = true;
                  });
                }
              }
              
            },
            icon: IconButton(
              icon: Icon(Icons.search, color: Constants().iconColor,),
              onPressed: () {
                try {
                  nextScreen(context, Search(searchName: "",));
                } catch(e) {
                  if (this.mounted) {
                    setState(() {
                      isErrorOccurred = true;
                    });
                  }
                }
              },
            ),) 
          ],

          elevation: 0,
          centerTitle: true,
          backgroundColor: Theme.of(context).primaryColor,
          title: Text(
            "LikeApp",
            style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w500, fontSize:  MediaQuery.of(context).size.height * 0.0205
            ),
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 50),
            children: <Widget>[
              Icon(
                Icons.account_circle,
                size: 150,
                color: Colors.grey,
              ),
              const SizedBox(height: 15,),
              Text(userName),
              Text(email),
              ElevatedButton(
              child: Text("LOGOUT"),
              onPressed: () {
                authServie.signOut();
                nextScreen(context, const LoginPage());
              },)
            ],
          ),
        ),

        body: 
        isErrorOccurred? Center(
          child: Column(
            children: [
              IconButton(onPressed: () {
                setState(() {
                  isErrorOccurred = false;
                  selectedIndex = 0;
                });
                gettingUserData();
                
              }, icon: Icon(Icons.refresh, size: MediaQuery.of(context).size.width * 0.08, color: Colors.blueGrey,),),
              Text("failed to load", style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.blueGrey))
            ],
          )
      ) :
        IndexedStack(
                      index: selectedIndex,
                      children: _widgetOptions,
                    ),
        bottomNavigationBar: isTablet?
          SalomonBottomBar(
          items: [
            SalomonBottomBarItem(
              icon: Icon(Icons.home_outlined, size: iconSize,),
              title: Text("home"),
              selectedColor:
                  Theme.of(context).primaryColor
            ),
            SalomonBottomBarItem(
              icon: Icon(Icons.favorite_border, size: iconSize,),
              title: Text("likes"),
              selectedColor:
                  Theme.of(context).primaryColor
            ),
            SalomonBottomBarItem(
              icon: Icon(Icons.post_add_outlined, size: iconSize,),
              title: Text("post"),
              selectedColor:
                  Theme.of(context).primaryColor
            ),
            SalomonBottomBarItem(
              icon: Icon(Icons.person_2_outlined, size: iconSize,),
              title: Text("profile"),
              selectedColor:
                  Theme.of(context).primaryColor
            ),
          ],
          currentIndex: selectedIndex,
          selectedItemColor: Colors.amber[800],
            onTap: (index) {
            setState(() {
              if (this.mounted) {
                if (index == 2) {
                  _showPicMenu();
                }
                else if (index == 0) {
                  
                  if (selectedIndex == 0) {
                    homeScrollController.animateTo(
                      0,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  }

                  selectedIndex = index;
                  
                }

                else if (index == 1) {
                  
                  if (selectedIndex == 1) {
                    likeScrollController.animateTo(
                      0,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  }

                  selectedIndex = index;
                  
                }

                else if (index == 3) {
                  
                  if (selectedIndex == 3) {
                    profileScrollController.animateTo(
                      0,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  }

                  selectedIndex = index;
                  
                }
                else {
                  selectedIndex = index;
              }
              }
            });
          },
        ) :
        SalomonBottomBar(
          items: [
            SalomonBottomBarItem(
              icon: Icon(Icons.home_outlined),
              title: Text("home"),
              selectedColor:
                  Theme.of(context).primaryColor
            ),
            SalomonBottomBarItem(
              icon: Icon(Icons.favorite_border),
              title: Text("likes"),
              selectedColor:
                  Theme.of(context).primaryColor
            ),
            SalomonBottomBarItem(
              icon: Icon(Icons.post_add_outlined),
              title: Text("post"),
              selectedColor:
                  Theme.of(context).primaryColor
            ),
            SalomonBottomBarItem(
              icon: Icon(Icons.person_2_outlined),
              title: Text("profile"),
              selectedColor:
                  Theme.of(context).primaryColor
            ),
          ],
          currentIndex: selectedIndex,
          selectedItemColor: Colors.amber[800],
            onTap: (index) {
            setState(() {
              if (this.mounted) {
                if (index == 2) {
                  _showPicMenu();
                }
                else if (index == 0) {
                  
                  if (selectedIndex == 0) {
                    try {
                      homeScrollController.animateTo(
                        0,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    } catch(e) {
                      logger.log(Level.error, e.toString());
                    }
                    
                  }

                  selectedIndex = index;
                  
                }

                else if (index == 1) {
                  
                  if (selectedIndex == 1) {
                    likeScrollController.animateTo(
                      0,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  }

                  selectedIndex = index;
                  
                }

                else if (index == 3) {
                  
                  if (selectedIndex == 3) {
                    profileScrollController.animateTo(
                      0,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  }

                  selectedIndex = index;
                  
                }
                else {
                  selectedIndex = index;
                }
              }
            });
          },
        ),
      )));

    } catch(e) {
      return Center(
          child: Column(
            children: [
              IconButton(onPressed: () {
                
                setState(() {
                  isErrorOccurred = false;
                  selectedIndex = 0;
                });
                gettingUserData();
                
              }, icon: Icon(Icons.refresh, size: MediaQuery.of(context).size.width * 0.08, color: Colors.blueGrey,),),
              Text("failed to load", style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05, color: Colors.blueGrey))
            ],
          )
      );

    }
  }

  double getFileSize(XFile file) {
    return File(file.path).lengthSync() / (1024 * 1024);
  }

  Future getImages() async {
    selectedImages = [];
    try {
        final status = await Permission.photos.request();
        if (status.isGranted) {
          final pickedFile = await picker.pickMultipleMedia(
          imageQuality: 100, maxHeight: 1000, maxWidth: 1000);
          List<XFile> xfilePick = pickedFile;
          setState(
            () {
              if (xfilePick.isNotEmpty) {
                if (xfilePick.length > 8) {
                  for (var i = 0; i < 8; i++) {
                    if (HelperFunctions().isVideoFile(File(xfilePick[i].path))) {
                      if (getFileSize(xfilePick[i]) > 40) {
                        final snackBar = SnackBar(
                          content: const Text('File size is so large!'),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      } else {
                        print("path" + xfilePick[i].path);
                        selectedImages.add(File(xfilePick[i].path));
                      }
                    }
                    else {
                      selectedImages.add(File(xfilePick[i].path));
                    }
                  }
                }
                else {
                  for (var i = 0; i < xfilePick.length; i++) {
                    if (HelperFunctions().isVideoFile(File(xfilePick[i].path))) {
                      if (getFileSize(xfilePick[i]) > 40) {
                        final snackBar = SnackBar(
                          content: const Text('File size is so large!'),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      } else {
                        print("path" + xfilePick[i].path);
                        selectedImages.add(File(xfilePick[i].path));
                      }
                    }
                    else {
                      selectedImages.add(File(xfilePick[i].path));
                    }
                  }
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nothing is selected')));
              }
            },
          );
        } 
        else if (status.isPermanentlyDenied) {
          openAppSettings();
        }
        else {
          await Permission.photos.request().then((value) async {
          if (value.isGranted) {

            final pickedFile = await picker.pickMultipleMedia(
            imageQuality: 100, maxHeight: 1000, maxWidth: 1000);
            List<XFile> xfilePick = pickedFile;
            setState(
              () {
                if (xfilePick.isNotEmpty) {
                  if (xfilePick.length > 8) {
                    final snackBar = SnackBar(
                      content: const Text('Until 8 images can be posted!'),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    for (var i = 0; i < 8; i++) {
                      if (HelperFunctions().isVideoFile(File(xfilePick[i].path))) {
                        if (getFileSize(xfilePick[i]) > 40) {
                          final snackBar = SnackBar(
                            content: const Text('File size is so large!'),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        } else {
                          print("path" + xfilePick[i].path);
                          selectedImages.add(File(xfilePick[i].path));
                        }
                      }
                      else {
                        selectedImages.add(File(xfilePick[i].path));
                      }
                      
                    }
                  }
                  else {
                    for (var i = 0; i < xfilePick.length; i++) {
                      if (HelperFunctions().isVideoFile(File(xfilePick[i].path))) {
                        if (getFileSize(xfilePick[i]) > 40) {
                          final snackBar = SnackBar(
                            content: const Text('File size is so large!'),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        } else {
                          print("path" + xfilePick[i].path);
                          selectedImages.add(File(xfilePick[i].path));
                        }
                      }
                      else {
                        selectedImages.add(File(xfilePick[i].path));
                      }
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Nothing is selected')));
                }
              },
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Permission needed')));
          } 
          });

          
        }

    } catch (e) {
      if (this.mounted) {
        setState(() {
          isImagesLoading = false;
          isErrorOccurred = true;
          selectedIndex = 0;
        });
      }
      logger.log(Level.error, "Error occurred while picking image\nerror: " + e.toString());
    }
  }

  Future<List<dynamic>> cropImages(List<File> medias) async {
    try {

      List<dynamic> files = [];

      for (var media in medias) {
        bool isVideo = HelperFunctions().isVideoFile(media);
        if (!isVideo) {
          bool isHorizontal = await isImageHorizontal(media);
          var croppedFile = await ImageCropper().cropImage(
            sourcePath: media.path,
            aspectRatio: isHorizontal? CropAspectRatio(ratioX: 1200, ratioY: 1200) : CropAspectRatio(ratioX: 900, ratioY: 1200),
            uiSettings: [
              AndroidUiSettings(
                  toolbarTitle: 'Cropper',
                  toolbarColor: Colors.deepOrange,
                  toolbarWidgetColor: Colors.white,),
              IOSUiSettings(
                title: 'Cropper',
                aspectRatioLockEnabled: true, 
                resetAspectRatioEnabled: false,
                aspectRatioPickerButtonHidden: true,
                rotateButtonsHidden: true
              ),
              WebUiSettings(
                context: context,
              ),
            ],
          );

          if (croppedFile != null) {
            files.add(croppedFile);
          }
        }
        else {
          files.add(media);
        }
        
      }

      return files;

    } catch(e) {

      setState(() {
        if (this.mounted) {
          isImagesLoading = false;
        }
      });

      return [];

    }
    
  }

  void _showPicMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0)
        )
      ),
      builder: (BuildContext context) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.picture_in_picture_alt),
                title: Text('No photo'),
                onTap: () {
                  setState(() {
                    _widgetOptions[2] = Post(images: []);
                    selectedIndex = 2;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.picture_as_pdf_outlined),
                title: Text('Select photo (Until 8 images or videos)'),
                onTap: () async{
                  // Navigator.pop(context);
                  try {
                    setState(() {
                      if (this.mounted) {
                        isImagesLoading = true;
                      }
                    });
                    await getImages();
                    setState(() {
                      if (this.mounted) {
                        isImagesLoading = false;
                      }
                    });
                    await cropImages(selectedImages).then((value) {

                      if (this.mounted) {
                        setState(() {
                          print(value);
                          _widgetOptions[2] = Post(images: value);
                          selectedIndex = 2;
                        });
                      }
                    });
                    
                  } catch(e) {
                    if (this.mounted) {
                      setState(() {
                        isImagesLoading = false;
                        isErrorOccurred = true;
                      });
                    }
                    logger.log(Level.error, "Error occurred while picking image\nerror: " + e.toString());
                  }
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02,)
            ],
          ),
        );
      }
    );
  }

  Future<bool> isImageHorizontal(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(Uint8List.fromList(bytes));

    return image!.width > image.height;
  }

}