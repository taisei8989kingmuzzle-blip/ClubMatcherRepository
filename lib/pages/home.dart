import 'package:club_matcher/models/ClubList_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
   

class _HomePageState extends State<HomePage> {
 bool _isLoggedIn = false;
  List<ClubListModels> clubs  = [];
  late final StreamSubscription<AuthState> _authSubscription;
  Future <void> _getClubs()  async {
    try{
      final fetchedClubs = await ClubListModels.getClubs();

      print("SUCCESSFULLY FETCHED COUNT: ${fetchedClubs.length}");

      setState(() {
        clubs = fetchedClubs;
      });
    } catch (e) {
      print ("error loading data: $e");
      
    }
    // Use .then() to wait for the Future to complete in the background
  }

  

  void _showAddClubDialog (BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController roomController = TextEditingController();
    final TextEditingController timeController = TextEditingController();
    final TextEditingController descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Club'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Club Name'),
                ),
                TextField(
                  controller: roomController,
                  decoration: const InputDecoration(labelText: 'Room'),
                ),
                TextField(
                  controller: timeController,
                  decoration: const InputDecoration(labelText: 'Time'),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
              ],
             ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
                ),
            ElevatedButton(
              onPressed: () async {
                final String name = nameController.text.trim();
                final String room = roomController.text.trim();
                final String time = timeController.text.trim();
                final String desc = descController.text.trim();

                if(name.isEmpty) return;

                try{
                  await Supabase.instance.client.from('ClubMatcher').insert({
                    'name': name,
                    'meeting_time': time,
                    'room': room,
                    'description': desc,
                  });

                  Navigator.pop(context);

                  _getClubs();
                } catch(e) {
                  print("Error occured during upload: $e");
                }
              },
              child: const Text ('Save'),
            )
            ]
        );
      }
      );
  }

  void showSignedOutSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Successfully Logged Out'))
    );
  }
  //initState only happens once in a lifecycle
  @override
  void initState() {
    super.initState();
    _isLoggedIn = Supabase.instance.client.auth.currentUser != null;
    _getClubs();
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      setState(() {
        _isLoggedIn = data.session != null;
      });
    });
  }

  @override
  void dispose() {
    //process of cleaning up
    _authSubscription.cancel();
    super.dispose();
  }


  final TextEditingController _searchClubController = TextEditingController();
String searchKey = "";
ClubListModels? selectedClub;
  @override
  Widget build(BuildContext context) {
   final List<ClubListModels> searchResult = clubs.where((clubs) => clubs.ClubName.toLowerCase().contains(searchKey.toLowerCase())).toList();
    //what list to actually display
    final List<ClubListModels> DisplayClub = searchKey.isEmpty? clubs : searchResult;
    
    return Scaffold(
      appBar: appBar(),
      
      backgroundColor: Color(0XFFA3D0D4),
     
      body: 
      
      SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 8.0, left: 15.0, right: 15.0),
              child: Image.asset(
                'assets/images/ClubMatcherBanner.png',
                height: 300,
                width: 500,
                fit: BoxFit.cover,
              ),
            ),
        
            _searchField(),
            SizedBox(height: 40,),
            Padding(
             padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: const Text(
              'Club',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
                ),
                SizedBox(width: 15,),
                
                  
                clubs.isEmpty
                  ?const Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue,
                    ),)
                  // height: 500,
                  // color: Colors.blue,
                  : Container(
                    
                    child: ListView.separated(

                      itemCount: DisplayClub.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      padding: EdgeInsets.symmetric(
                      horizontal: 25,
                      ),
                      separatorBuilder: (context, index) => SizedBox(height: 25,),
                      
                      itemBuilder: (context, index) {
                        final currentClub = DisplayClub[index];
        
                        final bool isExpanded = selectedClub?.ClubName == currentClub.ClubName;
                        return Column(
                        children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isExpanded) {
                                selectedClub = null; //program to close the club tab when the user clicked again
                              }else{
                                selectedClub = currentClub;
                              }
                            });
                          },
                         child: Container(
                          height: 80, 
                         
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50, 
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                
                              ),
                              const SizedBox(width: 16),
                              // text Value layout area
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      DisplayClub[index].ClubName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Room ${DisplayClub[index].Room}',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 13,
                                      ),
                                    ),
                                    
                                  ],
                                ),
                              ),
                              Icon(
                                isExpanded? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                color: Colors.grey,
                              )
                            ],
                          ),
                        )
                      ),
                      //the detail tab for the clicked club
                      if(isExpanded) _buildInlineDetailTab(currentClub),
                    ],
                 );
        
                      },
                    ),
                  ),
                
          ],
          
        
        
        
        ),
      ),
      
      floatingActionButton: 
      _isLoggedIn
      ?FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          _showAddClubDialog(context);
        },
        child: const Icon(Icons.add, color: Colors.white),
      )
      : null
      
  );
}
Widget _buildInlineDetailTab(ClubListModels club) {
  return Container(
    width: double.infinity,
    margin:const EdgeInsets.only(top: 4),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.blue.withOpacity(0.08),
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(15),
        bottomRight: Radius.circular(15),

      ),
      border: Border.all(color: Colors.blue.withOpacity(0.2)),

    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon (Icons.meeting_room_outlined, size: 18, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              "Full location DetailsL Room ${club.Room}",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Divider(color: Colors.black12),
          ),
          const Text(
            "About the club",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            club.Description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade800,
              height: 1.4,
            ),
          ),
      ],
    ),
  );
}

  Container _searchField() {
   
    return Container(
          margin: EdgeInsets.only(top: 40, left: 20, right: 20),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
              color: Colors.black.withValues(),
              blurRadius: 40, 
              spreadRadius: 0.0,
              )
            ],
          ),
          child: TextField(
            controller: _searchClubController,
            decoration: InputDecoration(
              
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.all(15),
              hintText: 'search Card Game Club',
              hintStyle: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(8.0),
                
                child: SvgPicture.asset(
                  'assets/icons/SearchIcon.svg',
                  height: 10.0,
                  width: 10.0,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              )
            ),
            onChanged: (value) {
                setState(() {
                  searchKey = _searchClubController.text.trim();
                  });
            },
          ),
        );
  }

  AppBar appBar() {
    bool _isHover = false;
    return AppBar(
      title: Text(
      'Club Matcher',
      style: TextStyle(
        color: Color(0XFF374649),
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
      ),
    ),
    backgroundColor: Color(0XFF6B91C9),
    centerTitle: true,
    elevation: 0.0,
    leading: 
    GestureDetector(
      onTap: () {

      },
    child: Container(
     margin: EdgeInsets.all(10),
      child: SvgPicture.asset('assets/icons/Screenshot 2026-05-22 220611.svg'),
      decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: Colors.grey,
      ),
    ),
    ),
  actions: [
   
    Row(
    
    children: [
      MouseRegion(
        onEnter: (event) => setState(() => _isHover = true),
        onExit: (event) => setState(() => _isHover = false),
      child: 

      GestureDetector(
        onTap: () async {
        await Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => const SignUpScreen()),
        );
        setState(() {});
        },
        child: Container(
           width: 150,
           height: 100,
          margin: const EdgeInsets.all(10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey,
          ),
          child: Text("Create Account",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      )
                      ),
            ),
          )
          
        ),

        if (_isLoggedIn)
        GestureDetector(
          onTap: () async{
            await Supabase.instance.client.auth.signOut();
            showSignedOutSnackBar();
          },
          child: 
          Container(
            width: 100,
            height: 100,
            margin: const EdgeInsets.all(10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey,
            ),
            child: Text("Sign Out",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        )),

          ),
        ),
       
       
       if(!_isLoggedIn) 
      GestureDetector(
        
        onTap: () async {
         
           
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SignInScreen()),
          );
        },
       
        child: 
      
        Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.all(10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey,
          ),
          child: Text("Sign In",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      )
                      ),
          
        )
   
        
      )
     
    ],
  
    )
    
  ]
    
    
  );
  }

}


class SignUpScreen extends StatefulWidget {
  const SignUpScreen ({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class SignInScreen extends StatefulWidget {
  const SignInScreen ({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future <void> _SignIn() async {
    try{
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        );
        if (mounted) {
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logged in successfully!')),
          );
          
          Navigator.pop(context);
        }
    } catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text ('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build (BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign in")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _SignIn, child: const Text('Sign In'))
          ],
        ),
      )
    );
  }
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  Future<void> _signUp() async {
    try{
      await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account successfully created. Please verify the account in your email.')),

        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error $e'), backgroundColor: Colors.red),
      );

    }
  }

  @override
  Widget build (BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text ('Create account')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Your Email address')),
            TextField(controller: _passwordController, decoration: InputDecoration(labelText: 'Create a password')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _signUp, child: const Text('Sign Up')),
          ]
        )
        )
      );
  }
}

class HomePage extends StatefulWidget {
  const HomePage ({super.key});

  @override
  State<HomePage> createState() => _HomePageState();

}




