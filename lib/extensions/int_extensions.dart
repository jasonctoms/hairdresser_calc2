extension IntExtensions on int {
  String toKroner() {
    var str = this.toString();
    RegExp reg = new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    Function matchFunc = (Match match) => '${match[1]} ';
    var formattedString = str.replaceAllMapped(reg, matchFunc);
    formattedString = formattedString + 'kr';
    return formattedString;
  }
}
