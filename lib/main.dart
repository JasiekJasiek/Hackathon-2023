import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

var locX = [52.5141, 52.5141, 52.5141, 52.5306, 52.5323, 52.5323, 52.5355, 52.5379, 52.5379, 52.539, 52.539, 52.5395, 52.5409, 52.5409, 52.5426, 52.5426, 52.543, 52.5434, 52.5437, 52.5437, 52.5446, 52.5446, 52.5452, 52.5458, 52.5458, 52.546, 52.5482, 52.55, 52.55, 52.5504, 52.5511, 52.5532, 52.5545, 52.5562, 52.5562, 52.5576, 52.5576, 52.5581, 52.559, 52.559, 52.5607, 52.5607, 52.5609];
var locY = [19.6411, 19.7516, 19.7583, 19.7286, 19.7183, 19.7286, 19.7169, 19.7116, 19.7499, 19.7084, 19.7183, 19.7116, 19.6903, 19.7, 19.7499, 19.7627, 19.7627, 19.7084, 19.6903, 19.6924, 19.6857, 19.7688, 19.7583, 19.6798, 19.6857, 19.6924, 19.6879, 19.683, 19.6879, 19.6798, 19.7, 19.6826, 19.6685, 19.6826, 19.683, 19.6537, 19.6743, 19.6743, 19.6537, 19.6685, 19.7169, 19.7516, 19.7017];

class User {
  final String name;
  final double kilometersDriven;

  User({required this.name, required this.kilometersDriven});
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Maps',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MyMapPage(),
        '/profile': (context) => const ProfilePage(),
        '/rewards': (context) => const RewardsPage(),
        '/ranking': (context) => const RankingPage(), // Dodaj trasę do strony rankingu
      },
    );
  }
}

class MyMapPage extends StatefulWidget {
  const MyMapPage({super.key});

  @override
  _MyMapPageState createState() => _MyMapPageState();
}

class _MyMapPageState extends State<MyMapPage> {
  late GoogleMapController mapController;
  double distanceInKilometers = 0.0;
  int elapsedTime = 0;
  double currentSpeed = 0.0;
  double burnedCalories = 0.0;
  double savedCarbonFootprint = 0.0;
  bool isTracking = false;
  late Position? previousPosition;
  late StreamSubscription<Position> positionStream;

  @override
  void initState() {
    super.initState();
    positionStream = Geolocator.getPositionStream(
      desiredAccuracy: LocationAccuracy.best,
    ).listen((Position position) {
      if (previousPosition != null && isTracking) {
        final distance = Geolocator.distanceBetween(
          previousPosition!.latitude,
          previousPosition!.longitude,
          position.latitude,
          position.longitude,
        );
        setState(() {
          elapsedTime += 1;
          currentSpeed = position.speed * 3.6;
          distanceInKilometers += distance / 1000;
          burnedCalories = 5.0;
          savedCarbonFootprint = 0.01;
          previousPosition = position;
        });
      }
    });
  }

  @override
  void dispose() {
    positionStream.cancel();
    super.dispose();
  }

  void startTracking() {
    setState(() {
      isTracking = true;
    });
  }

  void stopTracking() {
    setState(() {
      isTracking = false;
      elapsedTime = 0;
      distanceInKilometers = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Pozycje markerów
    List<LatLng> markerPositions = List.generate(locX.length, (index) => LatLng(locX[index], locY[index]));

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: AppBar(
          title: const Center(
            child: Text(
              'Czas na rower',
              style: TextStyle(fontSize: 40.0),
            ),
          ),
          centerTitle: false,
        ),
      ),
      endDrawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Padding(
                padding: EdgeInsets.only(bottom: 20.0),
                child: Text(
                  'Menu Aplikacji',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                  ),
                ),
              ),
            ),
            ListTile(
              title: const Text(
                'Profil',
                style: TextStyle(
                  fontSize: 32,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              title: const Text(
                'Nagrody',
                style: TextStyle(
                  fontSize: 32,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/rewards');
              },
            ),
            ListTile(
              title: const Text(
                'Regulamin',
                style: TextStyle(
                  fontSize: 32,
                ),
              ),
              onTap: () {},
            ),
            ListTile(
              title: const Text(
                'Polityka prywatności',
                style: TextStyle(
                  fontSize: 32,
                ),
              ),
              onTap: () {},
            ),
            ListTile(
              title: const Text(
                'Ranking', // Dodaj element menu dla strony rankingu
                style: TextStyle(
                  fontSize: 32,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, '/ranking'); // Przenieś użytkownika do strony rankingu
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              setState(() {
                mapController = controller;
              });
            },
            initialCameraPosition: const CameraPosition(
              target: LatLng(52.5455, 19.7078),
              zoom: 12.0,
            ),
            // Dodawanie markerów do mapy
            markers: Set<Marker>.from(markerPositions.map((position) {
              return Marker(
                markerId: MarkerId(position.toString()),
                position: position,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure), // Ikona markera
                infoWindow: const InfoWindow(title: 'Miejsce'), // Tytuł informacji o miejscu
              );
            })),
          ),
          Positioned(
            bottom: 20,
            left: (MediaQuery.of(context).size.width - 80) / 2,
            child: InkWell(
              onTap: () {
                if (isTracking) {
                  stopTracking();
                } else {
                  startTracking();
                }
              },
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isTracking ? Colors.red : Colors.green,
                ),
                child: Center(
                  child: Icon(
                    isTracking ? Icons.stop : Icons.play_arrow,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
          if (isTracking) // Wyświetl panel z danymi tylko jeśli śledzenie jest włączone
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.white.withOpacity(0.7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Czas: ${Duration(seconds: elapsedTime).toString().split('.').first}',
                      style: const TextStyle(fontSize: 20),
                    ),
                    Text(
                      'Prędkość: $currentSpeed km/h',
                      style: const TextStyle(fontSize: 20),
                    ),
                    Text(
                      'Dystans: $distanceInKilometers km',
                      style: const TextStyle(fontSize: 20),
                    ),
                    Text(
                      'Spalone kalorie: $burnedCalories kcal',
                      style: const TextStyle(fontSize: 20),
                    ),
                    Text(
                      'Zaoszczędzony ślad węglowy: ${savedCarbonFootprint.toStringAsFixed(2)} kg CO2',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: const Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Icon(
              Icons.sentiment_very_satisfied,
              size: 200,
              color: Colors.green,
            ),
          ),
          SizedBox(height: 20.0),
          ListTile(
            title: Text(
              'Imie: Jan',
              style: TextStyle(
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: Text(
              'Nazwisko: Szala',
              style: TextStyle(
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: Text(
              'Wiek: 19 lat',
              style: TextStyle(
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: Text(
              'Płeć: Mężczyzna',
              style: TextStyle(
                fontSize: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RewardsPage extends StatefulWidget {
  const RewardsPage({Key? key}) : super(key: key);

  @override
  _RewardsPageState createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  int userPoints = 1000;

  List<Reward> rewards = [
    Reward(name: 'Dzień wolny', price: '10000pkt', pointsRequired: 10000),
    Reward(name: 'Wcześniejsze wyjście z pracy o 1h', price: '1000pkt', pointsRequired: 1000),
    Reward(name: 'Darmowy Obiad', price: '800pkt', pointsRequired: 800),
    Reward(name: 'Darmowy owoc', price: '200pkt', pointsRequired: 200),
  ];

  void _claimReward(Reward reward) {
    if (userPoints >= reward.pointsRequired) {
      setState(() {
        userPoints -= reward.pointsRequired;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nie masz wystarczająco punktów, aby odebrać tę nagrodę.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nagrody',
          style: TextStyle(
            fontSize: 36,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: rewards.length,
        itemBuilder: (context, index) {
          final reward = rewards[index];
          return RewardItem(
            reward: reward,
            userPoints: userPoints,
            claimReward: _claimReward,
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Punkty: ',
              style: TextStyle(
                fontSize: 30,
              ),
            ),
            Text(
              ' $userPoints',
              style: const TextStyle(
                fontSize: 30,
              ),
            ),
            const Icon(
              Icons.whatshot,
              size: 30,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}

class RewardItem extends StatelessWidget {
  final Reward reward;
  final int userPoints;
  final Function(Reward) claimReward;

  const RewardItem({
    required this.reward,
    required this.userPoints,
    required this.claimReward,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        reward.name,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        reward.price,
        style: const TextStyle(
          fontSize: 20,
        ),
      ),
      trailing: ElevatedButton(
        onPressed: () {
          claimReward(reward);
        },
        child: const Text(
          'Odbierz',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}

class Reward {
  final String name;
  final String price;
  final int pointsRequired;

  Reward({
    required this.name,
    required this.price,
    required this.pointsRequired,
  });
}

List<User> users = [
  User(name: 'Jan', kilometersDriven: 150.0),
  User(name: 'Anna', kilometersDriven: 240.5),
  User(name: 'Piotrek', kilometersDriven: 32.5),
  User(name: 'Szymon', kilometersDriven: 200.5),
  User(name: 'Patryk', kilometersDriven: 1023.5),
  User(name: 'Artur', kilometersDriven: 234.5),
  User(name: 'Karolina', kilometersDriven: 567.5),
  User(name: 'Przemek', kilometersDriven: 890.5),
];

class RankingPage extends StatelessWidget {

  const RankingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sortuj użytkowników według ilości przejechanych kilometrów
    users.sort((a, b) => b.kilometersDriven.compareTo(a.kilometersDriven));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ranking'),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            title: Text('${index + 1}. ${user.name}',
              style: const TextStyle(fontSize: 34),),
            subtitle: Text('Przejechane kilometry: ${user.kilometersDriven} km',
              style: const TextStyle(fontSize: 26),),
          );
        },
      ),
    );
  }
}
