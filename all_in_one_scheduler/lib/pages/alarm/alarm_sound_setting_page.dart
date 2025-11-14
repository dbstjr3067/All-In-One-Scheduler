import 'package:flutter/material.dart';

// 사용자가 선택할 수 있는 알람음 목록
class SoundOption {
  final String name;
  final String description;
  final String imageUrl; // 이미지 URL 대체

  SoundOption({
    required this.name,
    required this.description,
    required this.imageUrl,
  });
}

final List<SoundOption> _soundOptions = [
  SoundOption(
    name: '공사소리',
    description: '중장비의 강력한 소음으로 당신의 잠을 깨워보세요.',
    imageUrl: 'https://placehold.co/100x100/A3E4D7/000?text=공사소리',
  ),
  SoundOption(
    name: '새들의 합창',
    description: '조용하고 평화로운 새 소리로 기분 좋게 시작하세요.',
    imageUrl: 'https://placehold.co/100x100/F5CBA7/000?text=새들의+합창',
  ),
  SoundOption(
    name: '소방차 사이렌',
    description: '긴급한 사이렌 소리가 당신을 깨웁니다.',
    imageUrl: 'https://placehold.co/100x100/D98880/000?text=사이렌',
  ),
];

// 알람음 설정 페이지 (AlarmSettingPage에서 호출)
class AlarmSoundSettingPage extends StatefulWidget {
  final String initialSoundAsset;

  const AlarmSoundSettingPage({
    Key? key,
    required this.initialSoundAsset,
  }) : super(key: key);

  @override
  State<AlarmSoundSettingPage> createState() => _AlarmSoundSettingPageState();
}

class _AlarmSoundSettingPageState extends State<AlarmSoundSettingPage> {
  late String _selectedSoundAsset;

  // 스타일 색상
  static const Color _cardColor = Color(0xFFEBEBFF);

  @override
  void initState() {
    super.initState();
    _selectedSoundAsset = widget.initialSoundAsset;
  }

  void _selectSound(String name) {
    setState(() {
      _selectedSoundAsset = name;
    });
  }

  void _saveSoundSetting() {
    Navigator.pop(context, _selectedSoundAsset);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('알람음 설정', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: _cardColor,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '소리 목록',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ..._soundOptions.map((option) {
                    final isSelected = _selectedSoundAsset == option.name;
                    return _buildSoundOption(option, isSelected);
                  }).toList(),
                ],
              ),
            ),
          ),
          _buildConfirmButton(context),
        ],
      ),
    );
  }

  Widget _buildSoundOption(SoundOption option, bool isSelected) {
    return GestureDetector(
      onTap: () => _selectSound(option.name),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.purple.shade700 : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 영역
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                option.imageUrl,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey[300],
                  child: const Icon(Icons.volume_up, color: Colors.black54),
                ),
              ),
            ),
            const SizedBox(width: 15),
            // 텍스트 영역
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    option.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            // 체크박스/라디오 버튼
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isSelected ? Colors.purple.shade700 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: Colors.black54)),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: _saveSoundSetting,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade700,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('저장', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}