import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
bool isLoading = true;

class ClubListModels {
  String ClubName;
  String Time;
  String Room;
  String Description;

  ClubListModels ({
    required this.ClubName,
    required this.Time,
    required this.Room, 
    required this.Description,
  });

  static List <ClubListModels> result = [];
  static List<ClubListModels> temp = [];
  
  factory ClubListModels.fromJson(Map<String, dynamic> json) {
    return ClubListModels(
      ClubName: json['name'] ?? 'Unnamed Club',
      Time: json['meeting_time'] ?? 'Time TBD', 
      Room: json['room']?? 'Room TBD', 
      Description: json['description'] ?? 'N/A',
      );
  }
  
  static Future <List<ClubListModels>> getClubs() async {
    try{
      final List <dynamic> response = await Supabase.instance.client.from('ClubMatcher').select();

      return response.map((row) {
        return ClubListModels.fromJson(row as Map<String, dynamic>);
      }).toList();
    } catch (error) {
      print ("Critical Supabase error: $error");
      return [];
    }

  }

  //  static Future<List <ClubListModels>> getClubs() async {
  //     await _fetchClubFromSupabase();
  //   return result;
  // }

  
}

// static Future <List<ClubListModels>> getClubs() async {
  //   try{
  //         final List<dynamic> res = await Supabase.instance.client.from('club').select();

  //         final List<ClubListModels> loadedClubs = res.map((row) {
  //           return ClubListModels.fromJson(row as Map<String, dynamic>);
  //         }).toList();
  //       if (loadedClubs.length == 0)
  //       {
  //         temp.add(
  //         ClubListModels(
  //           ClubName: 'Dog Club',
  //           Time: 'lunch',
  //           Room: 'Lab',
  //           Description: 'pat my dog'
  //           )
  //         );
  //         return temp;
  //       }
  //       else{
  //         return loadedClubs;
  //       }
   
  //   } catch (error) {
  //     print ("Supabase Fetch error: $error");
  //     return [];
  //   }
    
  // }