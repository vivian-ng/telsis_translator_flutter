class subcipher {
  static final Map<String, String> cipher_table = {
    'a': 'u',
    'b': 'b',
    'c': 'y',
    'd': 'd',
    'e': 'o',
    'f': 'f',
    'g': 'v',
    'h': 't',
    'i': 'i',
    'j': 's',
    'k': 'r',
    'l': 'q',
    'm': 'p',
    'n': 'n',
    'o': 'e',
    'p': 'm',
    'q': 'l',
    'r': 'k',
    's': 'j',
    't': 'h',
    'u': 'a',
    'v': 'g',
    'w': 'w',
    'x': 'x',
    'y': 'c',
    'z': 'z',
    'A': 'U',
    'B': 'B',
    'C': 'Y',
    'D': 'D',
    'E': 'O',
    'F': 'F',
    'G': 'V',
    'H': 'T',
    'I': 'I',
    'J': 'S',
    'K': 'R',
    'L': 'Q',
    'M': 'P',
    'N': 'N',
    'O': 'E',
    'P': 'M',
    'Q': 'L',
    'R': 'K',
    'S': 'J',
    'T': 'H',
    'U': 'A',
    'V': 'G',
    'W': 'W',
    'X': 'X',
    'Y': 'C',
    'Z': 'Z',
    ' ': ' ',
    '0': '0',
    '1': '1',
    '2': '2',
    '3': '3',
    '4': '4',
    '5': '5',
    '6': '6',
    '7': '7',
    '8': '8',
    '9': '9',
  };

  static String substitute(String c) {
    if (cipher_table.containsKey(c)) {
      return cipher_table[c] as String;
    } else {
      return c;
    }
  }
}
