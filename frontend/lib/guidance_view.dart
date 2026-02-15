import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'theme.dart';

class GuidanceView extends StatelessWidget {
  const GuidanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HerLunaTheme.backgroundBeige,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildPrimaryFocusCard(),
                  const SizedBox(height: 32),
                  _buildSectionTitle(
                    "COMMONLY HELPFUL OPTIONS (CHOOSE WHAT FITS)",
                  ),
                  const SizedBox(height: 16),
                  _buildChoiceCard(
                    icon: LucideIcons.utensilsCrossed,
                    iconColor: Colors.orangeAccent,
                    title: "Nutrition Choices",
                    options: [
                      "Pairing carbohydrates with a source of protein or healthy fat (like berries with Greek yogurt) which many find helpful for glucose management.",
                      "Prioritizing fiber-rich vegetables to support digestion and satiety.",
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildChoiceCard(
                    icon: LucideIcons.dumbbell,
                    iconColor: Colors.greenAccent,
                    title: "Movement Choices",
                    options: [
                      "A light walk or gentle yoga to encourage circulation as your body transitions out of the menstrual phase.",
                      "Low-impact strength training if you feel your energy levels are beginning to increase.",
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildChoiceCard(
                    icon: LucideIcons.moon,
                    iconColor: Colors.indigoAccent,
                    title: "Recovery Choices",
                    options: [
                      "Checking in with your stress levels, as many people with PCOS notice that stress can impact energy and insulin sensitivity.",
                      "Setting a gentle intention for the day to help reduce decision fatigue around self-care.",
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSupportNote(),
                  const SizedBox(height: 32),
                  _buildHabitAuditSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(LucideIcons.zap, size: 14, color: Colors.teal),
            const SizedBox(width: 8),
            Text(
              "DAILY LIFEGUIDE",
              style: GoogleFonts.quicksand(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.black45,
              ),
            ),
          ],
        ),
        Text(
          "PCOS Support",
          style: GoogleFonts.quicksand(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: HerLunaTheme.primaryPlum,
          ),
        ),
        Text(
          "Informed options for your specific rhythm",
          style: GoogleFonts.quicksand(fontSize: 16, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildPrimaryFocusCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: HerLunaTheme.primaryPlum,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: HerLunaTheme.primaryPlum.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Stack(
          children: [
            // --- THE SUBTLE LOGO WATERMARK ---
            Positioned(
              top: -30,
              right: -30,
              child: Opacity(
                opacity: 0.08, // Subtle "ghost" effect
                child: Image.asset(
                  'assets/logo.png',
                  width: 220,
                  color: Colors.black,
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
            ),

            // --- THE CONTENT ---
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "TODAY'S PRIMARY FOCUS",
                    style: GoogleFonts.quicksand(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Steady Energy & Gentle Momentum",
                    style: GoogleFonts.quicksand(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity, // Ensures it fills card width
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      "As you move further into the follicular phase, energy levels often begin to rise. Exploring ways to maintain blood sugar stability may help sustain this emerging energy throughout the day.",
                      style: GoogleFonts.quicksand(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.5,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.quicksand(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.black45,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildChoiceCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<String> options,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: GoogleFonts.quicksand(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: HerLunaTheme.primaryPlum,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...options.map(
            (option) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Icon(
                      LucideIcons.checkCircle2,
                      size: 16,
                      color: Colors.black12,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option,
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Text(
        "These are supportive options for you to consider based on how you feel today, not a set of requirements.",
        textAlign: TextAlign.center,
        style: GoogleFonts.quicksand(
          fontSize: 13,
          fontStyle: FontStyle.italic,
          color: Colors.black54,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildHabitAuditSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(LucideIcons.info, size: 14, color: Colors.teal),
            const SizedBox(width: 8),
            Text(
              "SPECIFIC HABIT AUDIT",
              style: GoogleFonts.quicksand(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black45,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "Ask how a specific habit might support your pcos",
          style: GoogleFonts.quicksand(fontSize: 14, color: Colors.black38),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'e.g. "How should I manage my afternoon caffeine given my PCOS?"',
                  style: GoogleFonts.quicksand(
                    fontSize: 15,
                    color: Colors.black38,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.chevronRight,
                  color: Colors.black26,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
