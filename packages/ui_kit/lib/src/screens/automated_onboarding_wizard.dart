import 'package:flutter/material.dart';
import 'package:shared_domain/shared_domain.dart';
import '../widgets/glass_container.dart';
import '../widgets/glass_button.dart';

class AutomatedOnboardingWizard extends StatefulWidget {
  final UserEntity user;
  final Function(UserEntity updatedUser) onComplete;

  const AutomatedOnboardingWizard({
    super.key,
    required this.user,
    required this.onComplete,
  });

  @override
  State<AutomatedOnboardingWizard> createState() => _AutomatedOnboardingWizardState();
}

class _AutomatedOnboardingWizardState extends State<AutomatedOnboardingWizard> {
  int _currentStep = 1;

  // Step 1: Personal Information (Figma Node 226:2657)
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final _dobController = TextEditingController(text: '15/08/1995');
  String _selectedGender = 'Male';
  final _cityController = TextEditingController(text: 'Mumbai');
  final _stateController = TextEditingController(text: 'Maharashtra');

  // Step 2: Permissions (Figma Node 226:2878)
  bool _allowLocation = true;
  bool _enableNotifications = true;

  // Step 3: Favorite Sports Selection (Figma Node 226:3065)
  final List<String> _allSports = ['Cricket', 'Football', 'Basketball', 'Badminton', 'Table Tennis', 'Volleyball'];
  final Set<String> _selectedSports = {'Cricket', 'Football'};

  // Step 4: See What You Can Do (Figma Nodes 226:3118 - 226:3247)
  int _featureIndex = 0;
  final List<Map<String, String>> _features = [
    {'emoji': '🏆', 'title': 'Join Tournaments', 'desc': 'Participate in local & national leagues.'},
    {'emoji': '👥', 'title': 'Create Teams', 'desc': 'Manage players, rosters, and team stats.'},
    {'emoji': '📺', 'title': 'Watch Live Scores', 'desc': 'Real-time ball-by-ball updates and stream.'},
    {'emoji': '🥇', 'title': 'Earn Badges', 'desc': 'Track achievements and referee certifications.'},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name.isEmpty ? 'Alex Vance' : widget.user.name);
    _emailController = TextEditingController(text: widget.user.email.isEmpty ? 'alex@sporto.com' : widget.user.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  void _finishOnboarding() {
    final updated = widget.user.copyWith(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      dob: _dobController.text.trim(),
      gender: _selectedGender,
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      favoriteSports: _selectedSports.toList(),
      isProfileComplete: true,
    );

    widget.onComplete(updated);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep > 1
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                onPressed: () => setState(() => _currentStep--),
              )
            : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: _buildCurrentStepContent(colorScheme),
                ),
              ),

              const SizedBox(height: 16),
              GlassButton(
                label: _currentStep == 4 ? 'Get Started' : 'Continue',
                isPrimary: true,
                onPressed: () {
                  if (_currentStep < 4) {
                    setState(() => _currentStep++);
                  } else {
                    _finishOnboarding();
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentStep) {
      case 1:
        return 'Complete Profile';
      case 2:
        return 'Permission';
      case 3:
        return 'Favorite Sports';
      case 4:
        return 'Overview';
      default:
        return '';
    }
  }

  Widget _buildCurrentStepContent(ColorScheme colorScheme) {
    switch (_currentStep) {
      case 1:
        return _buildStep1PersonalInfo(colorScheme);
      case 2:
        return _buildStep2Permissions(colorScheme);
      case 3:
        return _buildStep3FavoriteSports(colorScheme);
      case 4:
        return _buildStep4FeatureShowcase(colorScheme);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1PersonalInfo(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Information',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 16),

        // Profile Photo Upload Box matching Figma DocCard Upload
        GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.primary, width: 1.5),
                ),
                child: Icon(Icons.person, color: colorScheme.primary, size: 36),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Profile Photo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text('Upload a clear official photo for referee badge', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Upload', style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Text('Full Name', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            filled: true,
            fillColor: colorScheme.surfaceContainer,
            hintText: 'Enter your full name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 14),

        Text('Email Address', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            filled: true,
            fillColor: colorScheme.surfaceContainer,
            hintText: 'Enter your email address',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Date of Birth', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _dobController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: colorScheme.surfaceContainer,
                      hintText: 'DD/MM/YYYY',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Gender', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedGender,
                    dropdownColor: colorScheme.surface,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: colorScheme.surfaceContainer,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Male', child: Text('Male')),
                      DropdownMenuItem(value: 'Female', child: Text('Female')),
                      DropdownMenuItem(value: 'Others', child: Text('Others')),
                    ],
                    onChanged: (val) => setState(() => _selectedGender = val!),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('City', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: colorScheme.surfaceContainer,
                      hintText: 'Enter city name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('State', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _stateController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: colorScheme.surfaceContainer,
                      hintText: 'Enter state name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep2Permissions(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Permission',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 20),

        GlassContainer(
          padding: const EdgeInsets.all(18),
          margin: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Icon(Icons.location_on, color: colorScheme.primary, size: 32),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Allow Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text('Find tournaments near you.', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
                  ],
                ),
              ),
              Checkbox(
                value: _allowLocation,
                activeColor: colorScheme.primary,
                onChanged: (val) => setState(() => _allowLocation = val ?? false),
              ),
            ],
          ),
        ),

        GlassContainer(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(Icons.notifications_active, color: colorScheme.primary, size: 32),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Enable Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text('Get registration reminders.', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
                  ],
                ),
              ),
              Checkbox(
                value: _enableNotifications,
                activeColor: colorScheme.primary,
                onChanged: (val) => setState(() => _enableNotifications = val ?? false),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep3FavoriteSports(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Which sports do you love?',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 20),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _allSports.length,
          itemBuilder: (context, index) {
            final sport = _allSports[index];
            final isSelected = _selectedSports.contains(sport);

            return InkWell(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedSports.remove(sport);
                  } else {
                    _selectedSports.add(sport);
                  }
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: GlassContainer(
                borderRadius: 16,
                backgroundColor: isSelected ? colorScheme.primary.withValues(alpha: 0.2) : colorScheme.surfaceContainer,
                borderColor: isSelected ? colorScheme.primary : colorScheme.outline,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isSelected ? Icons.check_circle : Icons.sports_cricket,
                        color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        sport,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStep4FeatureShowcase(ColorScheme colorScheme) {
    final feat = _features[_featureIndex];

    return Column(
      children: [
        Text(
          'See What You Can Do',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 24),

        GlassContainer(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          hasGlow: true,
          child: Column(
            children: [
              Text(feat['emoji']!, style: const TextStyle(fontSize: 60)),
              const SizedBox(height: 16),
              Text(
                feat['title']!,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorScheme.primary),
              ),
              const SizedBox(height: 8),
              Text(
                feat['desc']!,
                textAlign: TextAlign.center,
                style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_features.length, (idx) {
            return GestureDetector(
              onTap: () => setState(() => _featureIndex = idx),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: idx == _featureIndex ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: idx == _featureIndex ? colorScheme.primary : colorScheme.outline,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
