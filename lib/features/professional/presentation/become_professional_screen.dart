// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/api_client.dart';

class BecomeProfessionalScreen extends StatefulWidget {
  const BecomeProfessionalScreen({super.key});

  @override
  State<BecomeProfessionalScreen> createState() =>
      _BecomeProfessionalScreenState();
}

class _BecomeProfessionalScreenState extends State<BecomeProfessionalScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _feeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String _selectedProfessionType = 'Select profession type';
  String _selectedMode = 'Both';
  String _selectedCity = 'Select City';

  bool _isLoading = false;

  final List<String> professionTypes = [
    'Select profession type',
    'Doctor',
    'Lawyer',
    'Tutor',
    'Therapist',
    'Technician',
    'Consultant',
    'Other',
  ];

  final List<String> modes = ['Online', 'Offline', 'Both'];

  final List<String> cities = [
    'Select City',
    'Hyderabad',
    'Kondotty',
    'Bangalore',
    'Mumbai',
    'Chennai',
    'Delhi',
    'Kolkata',
  ];

  final List<String> selectedTags = [];

  final List<String> suggestedTags = [
    'Home visit',
    'Emergency',
    'Weekend only',
    'Kids friendly',
    'Online only',
    '24/7',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(title: const Text('Become a Professional')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(context),
                const SizedBox(height: 24),
                _buildSectionTitle('Basic details'),
                const SizedBox(height: 12),
                _buildProfessionDropdown(),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _titleController,
                  label: 'Profile title',
                  hint: 'e.g. Senior cardiologist, Civil lawyer, Math tutor',
                  icon: Icons.badge_outlined,
                ),
                const SizedBox(height: 12),
                _buildAboutField(),
                const SizedBox(height: 24),

                _buildSectionTitle('Location & availability'),
                const SizedBox(height: 12),
                _buildCityDropdown(),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _locationController,
                  label: 'Address / Area (optional)',
                  hint: 'e.g. MG Road, JP Nagar...',
                  icon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 12),
                _buildModeChips(),
                const SizedBox(height: 24),

                _buildSectionTitle('Consultation & fees'),
                const SizedBox(height: 12),
                _buildFeeField(),
                const SizedBox(height: 12),
                _buildExperienceField(),
                const SizedBox(height: 24),

                _buildSectionTitle('Highlights (optional)'),
                const SizedBox(height: 8),
                const Text(
                  'Add a few tags that describe your service',
                  style: TextStyle(fontSize: 13, color: AppTheme.textLight),
                ),
                const SizedBox(height: 12),
                _buildTagChips(),
                const SizedBox(height: 24),

                _buildSectionTitle('Verification (for admin)'),
                const SizedBox(height: 8),
                _buildVerificationHintCard(),
                const SizedBox(height: 24),

                _buildSubmitButton(context),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.workspace_premium_outlined,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Fill these details to show your profile to users after admin approval.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppTheme.textDark,
      ),
    );
  }

  Widget _buildProfessionDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedProfessionType,
        decoration: InputDecoration(
          labelText: 'Profession type',
          labelStyle: const TextStyle(color: AppTheme.textLight),
          prefixIcon: const Icon(
            Icons.work_outline_rounded,
            color: AppTheme.primaryBlue,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        items: professionTypes.map((profession) {
          return DropdownMenuItem<String>(
            value: profession,
            child: Text(
              profession,
              style: TextStyle(
                color: profession == 'Select profession type'
                    ? AppTheme.textLight
                    : AppTheme.textDark,
              ),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedProfessionType = value!;
          });
        },
        validator: (value) {
          if (value == null || value == 'Select profession type') {
            return 'Please select a profession type';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCityDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedCity,
        decoration: InputDecoration(
          labelText: 'City',
          labelStyle: const TextStyle(color: AppTheme.textLight),
          prefixIcon: const Icon(
            Icons.location_city_outlined,
            color: AppTheme.primaryGreen,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        items: cities.map((city) {
          return DropdownMenuItem<String>(
            value: city,
            child: Text(
              city,
              style: TextStyle(
                color: city == 'Select City'
                    ? AppTheme.textLight
                    : AppTheme.textDark,
              ),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedCity = value!;
          });
        },
        validator: (value) {
          if (value == null || value == 'Select City') {
            return 'Please select a city';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppTheme.textLight),
          hintText: hint,
          hintStyle: const TextStyle(color: AppTheme.textLight),
          prefixIcon: Icon(icon, color: AppTheme.primaryBlue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) {
          if (maxLines == 1 && (value == null || value.trim().isEmpty)) {
            return 'Required field';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildAboutField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: _aboutController,
        maxLines: 4,
        decoration: InputDecoration(
          labelText: 'About your service',
          labelStyle: const TextStyle(color: AppTheme.textLight),
          hintText:
              'Briefly describe what you offer, your expertise, and how you help users.',
          hintStyle: const TextStyle(color: AppTheme.textLight),
          alignLabelWithHint: true,
          prefixIcon: const Icon(
            Icons.description_outlined,
            color: AppTheme.primaryBlue,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please describe your service';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildModeChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Consultation mode',
          style: TextStyle(fontSize: 14, color: AppTheme.textLight),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: modes.map((mode) {
            final isSelected = _selectedMode == mode;
            return ChoiceChip(
              label: Text(mode),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _selectedMode = mode;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: AppTheme.primaryBlue.withValues(alpha: 0.15),
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primaryBlue : AppTheme.textDark,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? AppTheme.primaryBlue
                      : Colors.grey.shade300,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFeeField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: _feeController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Approx. consultation fee',
          labelStyle: const TextStyle(color: AppTheme.textLight),
          hintText: 'e.g. 500',
          prefixIcon: const Icon(
            Icons.currency_rupee_outlined,
            color: AppTheme.primaryGreen,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter a fee (approx.)';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildExperienceField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: _experienceController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Years of experience',
          labelStyle: const TextStyle(color: AppTheme.textLight),
          hintText: 'e.g. 5',
          prefixIcon: const Icon(
            Icons.timeline_outlined,
            color: AppTheme.primaryBlue,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter your experience';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTagChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: suggestedTags.map((tag) {
        final isSelected = selectedTags.contains(tag);
        return FilterChip(
          label: Text(tag),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                selectedTags.add(tag);
              } else {
                selectedTags.remove(tag);
              }
            });
          },
          backgroundColor: Colors.white,
          selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.15),
          labelStyle: TextStyle(
            color: isSelected ? AppTheme.primaryGreen : AppTheme.textDark,
            fontSize: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade300,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildVerificationHintCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.25)),
      ),
      child: const Row(
        children: [
          Icon(Icons.verified_user_outlined, color: AppTheme.primaryBlue),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Admins will review your details before approving your professional profile. They may contact you if more information is needed.',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.darkBlue,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState?.validate() ?? false) {
            setState(() => _isLoading = true);

            try {
              await ApiClient.applyProfessional(
                title: _titleController.text.trim(),
                professionType: _selectedProfessionType.toLowerCase(),
                categorySlug: _selectedProfessionType.toLowerCase().replaceAll(
                  ' ',
                  '-',
                ),
                about: _aboutController.text.trim(),
                city: _selectedCity,
                consultationMode: _selectedMode.toLowerCase(),
                baseFee: int.parse(_feeController.text.trim()),
                yearsExperience: int.parse(_experienceController.text.trim()),
                address: _locationController.text.trim().isEmpty
                    ? null
                    : _locationController.text.trim(),
                tags: selectedTags.isEmpty ? null : selectedTags,
              );

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Application submitted! You will be notified after admin approval.',
                    ),
                    backgroundColor: AppTheme.primaryGreen,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
                Navigator.pop(context);
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            } finally {
              if (mounted) {
                setState(() => _isLoading = false);
              }
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Submit for review',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _aboutController.dispose();
    _experienceController.dispose();
    _feeController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}
