import 'package:blogapp/services/sqflite_helper.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:blogapp/localization/AppLocalizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> {
  late Locale _locale = Locale('fr');

  Iterable<Locale> lang = [
    Locale('en'),
    Locale('fr'),
    Locale('ar'),
  ];

  void setLocale(Locale value) {
    setState(() {
      _locale = value;
    });
  }

  void getLang() async {
    final prefs = await SharedPreferences.getInstance();

    final String? selectedLang = prefs.getString('lang');
    print(selectedLang);
    setState(() {
      _locale = Locale(selectedLang ?? 'en');
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        supportedLocales: lang,
        locale: _locale,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: MyHomePage(),
        title: "",
        theme: ThemeData(fontFamily: 'BaiJamjuree'));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  BorderRadiusGeometry radius = const BorderRadius.only(
    topLeft: Radius.circular(24.0),
    topRight: Radius.circular(24.0),
  );
  final PanelController _pc = PanelController();
  togglePanel() => _pc.isPanelOpen ? _pc.close() : _pc.open();

  final PanelController _pc1 = PanelController();
  togglePanel1() => _pc1.isPanelOpen ? _pc1.close() : _pc1.open();

  final _formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool isUpdate = false;
  List posts = [];

  List onePost = [];

  _getPosts() async {
    var resp = await SQLHelper.getPosts();
    setState(() {
      posts = resp;
    });
  }

  _getPostById(int post_id) async {
    var resp = await SQLHelper.getPostById(post_id);
    setState(() {
      onePost = resp;
      print(onePost);
    });

    togglePanel1();
  }

  _deletePost(int post_id) async {
    print(post_id);
    var resp = await SQLHelper.deletePost(post_id);
    _getPosts();
  }

  _getPostByIdUpdate(int post_id) async {
    var resp = await SQLHelper.getPostById(post_id);
    setState(() {
      isUpdate = true;
      onePost = resp;
    });

    titleController.text =
        onePost.isNotEmpty ? onePost[0]['title'] : "Title not found";

    descriptionController.text = onePost.isNotEmpty
        ? onePost[0]['description']
        : "Description not found";

    togglePanel();
  }

  void saveLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang', lang);
  }

  final test = _MyAppState();

  var myStateClass = _MyAppState();

  @override
  void initState() {
    _getPosts();
    MyApp.of(context)!.getLang();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(AppLocalizations.of(context)!.translate('title') ?? ""),
        actions: [
          TextButton(
              onPressed: () {
                MyApp.of(context)!.setLocale(Locale('en'));
                saveLanguage('en');
              },
              child: Text('EN', style: TextStyle(color: Colors.white))),
          TextButton(
              onPressed: () {
                MyApp.of(context)!.setLocale(Locale('fr'));
                saveLanguage('fr');
              },
              child: Text('FR', style: TextStyle(color: Colors.white))),
          TextButton(
              onPressed: () {
                MyApp.of(context)!.setLocale(Locale('ar'));
                saveLanguage('ar');
              },
              child: Text('AR', style: TextStyle(color: Colors.white))),
        ],
      ),
      body: Stack(children: [
        ListView.builder(
            itemCount: posts.length,
            itemBuilder: (BuildContext ctxt, int Index) {
              var title = posts[Index]['title'];
              var Id = posts[Index]['id'];
              var description = posts[Index]['description'];
              var splitted_title = title.split(' ');
              return GestureDetector(
                onTap: () => _getPostById(Id),
                child: Card(
                  elevation: 3,
                  child: Container(
                      margin: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.blue,
                                ),
                                color: Colors.transparent),
                            child: Center(
                                child: Text(
                              splitted_title[0].substring(0, 1).toUpperCase() ??
                                  "" +
                                      splitted_title[1]
                                          .substring(0, 1)
                                          .toUpperCase() ??
                                  "",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            )),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            height: 80,
                            width: 170,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title.length > 15
                                        ? title.substring(0, 15) + '...'
                                        : title,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    description.length > 30
                                        ? description.substring(0, 30) + '...'
                                        : description,
                                    style: TextStyle(fontSize: 15),
                                  )
                                ]),
                          ),
                          IconButton(
                              onPressed: () => _getPostByIdUpdate(Id),
                              icon: Icon(Icons.edit)),
                          IconButton(
                              onPressed: () => _deletePost(Id),
                              icon: Icon(Icons.delete_outline_outlined))
                        ],
                      )),
                ),
              );
            }),
        SlidingUpPanel(
          controller: _pc1,
          backdropEnabled: true,
          minHeight: 0,
          maxHeight: 600,
          parallaxEnabled: true,
          parallaxOffset: .5,
          collapsed: Container(
              // decoration: BoxDecoration(!=''
              // color: Colors.blueGrey,
              //  borderRadius: radius
              // ),
              ),
          panel: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Container(
                //padding: const EdgeInsets.all(15),
                //height: screenHeight * 0.2,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(15),
                      child: Text(
                        AppLocalizations.of(context)!.translate('view_post') ??
                            "",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 500,
                      padding: EdgeInsets.all(15),
                      child: ListView(
                        children: [
                          const SizedBox(height: 10),
                          Text(
                            onePost.isNotEmpty
                                ? onePost[0]['title']
                                : "Title not found",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          const SizedBox(height: 10),
                          Flexible(
                            child: Text(
                              onePost.isNotEmpty
                                  ? onePost[0]['description']
                                  : "Description not found",
                              style: TextStyle(fontSize: 15),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              )
            ],
          ),
          borderRadius: radius,
        ),
        SlidingUpPanel(
          controller: _pc,
          backdropEnabled: true,
          minHeight: 0,
          maxHeight: 550,
          parallaxEnabled: true,
          parallaxOffset: .5,
          collapsed: Container(
              // decoration: BoxDecoration(!=''
              // color: Colors.blueGrey,
              //  borderRadius: radius
              // ),
              ),
          panel: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Container(
                //padding: const EdgeInsets.all(15),
                //height: screenHeight * 0.2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(15),
                      child: Text(
                        isUpdate == true
                            ? AppLocalizations.of(context)!
                                    .translate('update_post') ??
                                ""
                            : AppLocalizations.of(context)!
                                    .translate('create_post') ??
                                "",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                        padding: const EdgeInsets.all(10),
                        child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    AppLocalizations.of(context)!
                                            .translate('post_title') ??
                                        "",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: titleController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return AppLocalizations.of(context)!
                                              .translate(
                                                  'post_title_required') ??
                                          "";
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.multiline,
                                  textInputAction: TextInputAction.newline,
                                  maxLines: null,
                                  decoration: InputDecoration(
                                    //prefixIcon: Icon(Icons.account_circle_outlined),
                                    hintText: AppLocalizations.of(context)!
                                            .translate('enter_post_title') ??
                                        "",
                                    border: OutlineInputBorder(),
                                    //labelText: "Vehicle's initial odameter",
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                    AppLocalizations.of(context)!
                                            .translate('post_description') ??
                                        "",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: descriptionController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return AppLocalizations.of(context)!
                                              .translate(
                                                  'post_description_required') ??
                                          "";
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.multiline,
                                  textInputAction: TextInputAction.newline,
                                  maxLines: 5,
                                  decoration: InputDecoration(
                                    //prefixIcon: Icon(Icons.account_circle_outlined),
                                    hintText: AppLocalizations.of(context)!
                                            .translate(
                                                'enter_post_description') ??
                                        "",
                                    border: OutlineInputBorder(),
                                    //labelText: "Vehicle's initial odameter",
                                  ),
                                )
                              ],
                            ))),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: 400,
                      margin: const EdgeInsets.all(10),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.blue,
                          onPrimary: Colors.white,
                          //shadowColor: Colors.greenAccent,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            //side: const BorderSide(color: Colors.black),
                          ),
                          minimumSize: const Size(100, 60), //////// HERE
                        ),
                        child: Row(
                          children: [
                            Spacer(),
                            isUpdate == true
                                ? Icon(Icons.edit)
                                : Icon(Icons.check),
                            SizedBox(width: 5),
                            Text(
                              isUpdate == true
                                  ? AppLocalizations.of(context)!
                                          .translate('update') ??
                                      ""
                                  : AppLocalizations.of(context)!
                                          .translate('save') ??
                                      "",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Spacer()
                          ],
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            var postData = 0;
                            int postId =
                                onePost.isNotEmpty ? onePost[0]['id'] : 0;
                            if (isUpdate == true) {
                              postData = await SQLHelper.updatePost(
                                  postId,
                                  titleController.text,
                                  descriptionController.text);
                            } else {
                              postData = await SQLHelper.savePost(
                                  titleController.text,
                                  descriptionController.text);
                            }

                            if (postData != null) {
                              var resp = await SQLHelper.getPosts();
                              setState(() {
                                posts = resp;
                                print(posts);
                              });

                              _formKey.currentState!.reset();
                              togglePanel();
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          borderRadius: radius,
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            isUpdate = false;
          });
          titleController.text = "";
          descriptionController.text = "";
          togglePanel();
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
