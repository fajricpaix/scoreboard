String capitalizeWords(String input, {int maxWords = 10}) {
	final normalized = input.trim().replaceAll(RegExp(r'\s+'), ' ');
	if (normalized.isEmpty) {
		return '';
	}

	final words = normalized.split(' ');
	final limitedWords = words.take(maxWords);

	return limitedWords
			.map((word) => '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
			.join(' ');
}

bool isWordCountBetween1And10(String input) {
	final normalized = input.trim().replaceAll(RegExp(r'\s+'), ' ');
	if (normalized.isEmpty) {
		return false;
	}

	final count = normalized.split(' ').length;
	return count >= 1 && count <= 10;
}
