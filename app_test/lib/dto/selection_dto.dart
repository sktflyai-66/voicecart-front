class SelectionDTO {
  final String selection;

  SelectionDTO(this.selection);

  Map<String, dynamic> toJson() => {
        'selection': selection,
      };
}
 
