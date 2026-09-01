import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ui_kit/ui_kit.dart';

const _googleMapsApiKey = 'AIzaSyBl0Pm1-cZM3-IdYhEkmEQ2A4XxSJpIRdQ';
const _hyderabad = LatLng(17.385044, 78.486671);

class VenueLocationSelection {
  const VenueLocationSelection({
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  final String address;
  final double latitude;
  final double longitude;
}

class VenueLocationPickerScreen extends StatefulWidget {
  const VenueLocationPickerScreen({
    super.key,
    this.initialAddress,
    this.initialLatitude,
    this.initialLongitude,
  });

  final String? initialAddress;
  final double? initialLatitude;
  final double? initialLongitude;

  @override
  State<VenueLocationPickerScreen> createState() =>
      _VenueLocationPickerScreenState();
}

class _VenueLocationPickerScreenState extends State<VenueLocationPickerScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final _places = const _GooglePlacesClient();

  GoogleMapController? _mapController;
  Timer? _searchDebounce;
  LatLng _target = _hyderabad;
  String _address = '';
  List<_PlaceSuggestion> _suggestions = const [];
  bool _searching = false;
  bool _resolvingAddress = false;
  bool _locationPermissionGranted = false;
  bool _initializingFromAddress = false;
  String? _errorMessage;
  int _requestVersion = 0;
  bool _skipNextReverseGeocode = false;

  @override
  void initState() {
    super.initState();
    final latitude = widget.initialLatitude;
    final longitude = widget.initialLongitude;
    if (latitude != null && longitude != null) {
      _target = LatLng(latitude, longitude);
    }
    _address = widget.initialAddress?.trim() ?? '';
    _initializingFromAddress =
        _address.isNotEmpty && (latitude == null || longitude == null);
    _searchFocusNode.addListener(_handleSearchFocus);
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchFocusNode.removeListener(_handleSearchFocus);
    _searchFocusNode.dispose();
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _handleSearchFocus() {
    if (mounted) setState(() {});
  }

  Future<void> _checkLocationPermission() async {
    final status = await Permission.location.status;
    if (!mounted) return;
    setState(() {
      _locationPermissionGranted = status.isGranted || status.isLimited;
    });
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    final query = value.trim();
    if (query.length < 3) {
      setState(() {
        _suggestions = const [];
        _searching = false;
        _errorMessage = null;
      });
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      _search(query);
    });
  }

  Future<void> _search(String query) async {
    final version = ++_requestVersion;
    setState(() {
      _searching = true;
      _errorMessage = null;
    });
    try {
      final results = await _places.autocomplete(query, near: _target);
      if (!mounted || version != _requestVersion) return;
      setState(() {
        _suggestions = results;
        _searching = false;
        if (results.isEmpty) _errorMessage = 'No matching locations found.';
      });
    } catch (_) {
      if (!mounted || version != _requestVersion) return;
      setState(() {
        _suggestions = const [];
        _searching = false;
        _errorMessage = 'Could not search locations. Please try again.';
      });
    }
  }

  Future<void> _selectSuggestion(_PlaceSuggestion suggestion) async {
    FocusScope.of(context).unfocus();
    final version = ++_requestVersion;
    setState(() {
      _suggestions = const [];
      _resolvingAddress = true;
      _errorMessage = null;
      _searchController.text = suggestion.description;
    });
    try {
      final place = await _places.placeDetails(suggestion.placeId);
      if (!mounted || version != _requestVersion) return;
      _skipNextReverseGeocode = true;
      setState(() {
        _target = place.position;
        _address = place.address;
        _resolvingAddress = false;
      });
      await _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: place.position, zoom: 17),
        ),
      );
    } catch (_) {
      if (!mounted || version != _requestVersion) return;
      setState(() {
        _resolvingAddress = false;
        _errorMessage = 'Could not open this location. Please try again.';
      });
    }
  }

  Future<void> _resolveMapCenter() async {
    if (_initializingFromAddress) return;
    if (_skipNextReverseGeocode) {
      _skipNextReverseGeocode = false;
      return;
    }
    final target = _target;
    final version = ++_requestVersion;
    setState(() {
      _resolvingAddress = true;
      _errorMessage = null;
    });
    try {
      final address = await _places.reverseGeocode(target);
      if (!mounted || version != _requestVersion) return;
      setState(() {
        _address = address;
        _resolvingAddress = false;
      });
    } catch (_) {
      if (!mounted || version != _requestVersion) return;
      setState(() {
        _resolvingAddress = false;
        _errorMessage = 'Move the map or search to select a valid address.';
      });
    }
  }

  void _confirm() {
    final address = _address.trim();
    if (address.isEmpty || _resolvingAddress) return;
    Navigator.of(context).pop(
      VenueLocationSelection(
        address: address,
        latitude: _target.latitude,
        longitude: _target.longitude,
      ),
    );
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;
    if (!_initializingFromAddress) return;
    try {
      final place = await _places.geocodeAddress(_address);
      if (!mounted) return;
      _skipNextReverseGeocode = true;
      setState(() {
        _target = place.position;
        _address = place.address;
        _initializingFromAddress = false;
      });
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: place.position, zoom: 17),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _initializingFromAddress = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tokens = context.sporto;
    final layout = context.sportoLayout;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return SportoScreenShell(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Select Venue Location'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: ClipRect(
              child: GoogleMap(
                initialCameraPosition:
                    CameraPosition(target: _target, zoom: 15),
                onMapCreated: _onMapCreated,
                onCameraMove: (position) => _target = position.target,
                onCameraIdle: _resolveMapCenter,
                onTap: (position) {
                  FocusScope.of(context).unfocus();
                  _mapController?.animateCamera(
                    CameraUpdate.newLatLng(position),
                  );
                },
                myLocationEnabled: _locationPermissionGranted,
                myLocationButtonEnabled: _locationPermissionGranted,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: true,
                style: _darkMapStyle,
              ),
            ),
          ),
          IgnorePointer(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 42),
                child: Icon(
                  Icons.location_on_rounded,
                  size: 48,
                  color: cs.primary,
                  shadows: const [
                    Shadow(color: Colors.black54, blurRadius: 10),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: layout.space16,
            left: layout.space16,
            right: layout.space16,
            child: Column(
              children: [
                SportoTextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  hint: 'Search area, landmark or venue',
                  prefix:
                      Icon(Icons.search_rounded, color: cs.onSurfaceVariant),
                  suffixIcon: _searching
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: cs.primary,
                          ),
                        )
                      : _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                              icon: Icon(Icons.close_rounded,
                                  color: cs.onSurfaceVariant, size: 20),
                            ),
                  onChanged: (value) {
                    setState(() {});
                    _onSearchChanged(value);
                  },
                ),
                if (_searchFocusNode.hasFocus &&
                    (_suggestions.isNotEmpty || _errorMessage != null)) ...[
                  const SizedBox(height: 8),
                  SportoCard(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: _suggestions.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(14),
                            child: Text(
                              _errorMessage!,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          )
                        : ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 270),
                            child: ListView.separated(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemCount: _suggestions.length,
                              separatorBuilder: (_, __) => Divider(
                                height: 1,
                                color: tokens.border,
                              ),
                              itemBuilder: (context, index) {
                                final suggestion = _suggestions[index];
                                return ListTile(
                                  dense: true,
                                  leading: Icon(Icons.location_on_outlined,
                                      color: cs.primary),
                                  title: Text(
                                    suggestion.primaryText,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: cs.onSurface),
                                  ),
                                  subtitle: suggestion.secondaryText.isEmpty
                                      ? null
                                      : Text(
                                          suggestion.secondaryText,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                  onTap: () => _selectSuggestion(suggestion),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            left: layout.space16,
            right: layout.space16,
            bottom: layout.space16 + bottomInset,
            child: SportoCard(
              padding: EdgeInsets.all(layout.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.place_rounded, color: cs.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Selected location',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (_resolvingAddress)
                    Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: cs.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text('Finding address...',
                            style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    )
                  else
                    Text(
                      _address.isEmpty
                          ? 'Move the map or search for a location.'
                          : _address,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: _address.isEmpty
                                ? cs.onSurfaceVariant
                                : cs.onSurface,
                          ),
                    ),
                  if (_errorMessage != null && !_searchFocusNode.hasFocus) ...[
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: cs.error),
                    ),
                  ],
                  const SizedBox(height: 16),
                  PrimaryButton(
                    width: double.infinity,
                    label: 'Confirm Location',
                    disabled: _address.isEmpty || _resolvingAddress,
                    onPressed: _confirm,
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

class _GooglePlacesClient {
  const _GooglePlacesClient();

  Future<List<_PlaceSuggestion>> autocomplete(
    String query, {
    required LatLng near,
  }) async {
    try {
      final json = await _postJson(
        Uri.https('places.googleapis.com', '/v1/places:autocomplete'),
        body: {
          'input': query,
          'includedRegionCodes': ['in'],
          'locationBias': {
            'circle': {
              'center': {
                'latitude': near.latitude,
                'longitude': near.longitude,
              },
              'radius': 50000.0,
            },
          },
        },
        headers: {
          'X-Goog-Api-Key': _googleMapsApiKey,
          'X-Goog-FieldMask': 'suggestions.placePrediction.placeId,'
              'suggestions.placePrediction.text.text,'
              'suggestions.placePrediction.structuredFormat.mainText.text,'
              'suggestions.placePrediction.structuredFormat.secondaryText.text',
        },
      );
      final suggestions = json['suggestions'];
      if (suggestions is! List) return const [];
      return suggestions
          .whereType<Map<String, dynamic>>()
          .map(_PlaceSuggestion.fromJson)
          .where((item) => item.placeId.isNotEmpty)
          .toList(growable: false);
    } on HttpException {
      return _legacyAutocomplete(query, near: near);
    }
  }

  Future<List<_PlaceSuggestion>> _legacyAutocomplete(
    String query, {
    required LatLng near,
  }) async {
    final json = await _getJson(
      Uri.https('maps.googleapis.com', '/maps/api/place/autocomplete/json', {
        'input': query,
        'key': _googleMapsApiKey,
        'components': 'country:in',
        'location': '${near.latitude},${near.longitude}',
        'radius': '100000',
      }),
    );
    _ensureSuccess(json);
    final predictions = json['predictions'];
    if (predictions is! List) return const [];
    return predictions
        .whereType<Map<String, dynamic>>()
        .map(_PlaceSuggestion.fromLegacyJson)
        .where((item) => item.placeId.isNotEmpty)
        .toList(growable: false);
  }

  Future<_ResolvedPlace> placeDetails(String placeId) async {
    final json = await _getJson(
      Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
        'place_id': placeId,
        'key': _googleMapsApiKey,
      }),
    );
    _ensureSuccess(json);
    final results = json['results'];
    if (results is! List || results.isEmpty) throw const FormatException();
    final result = results.first;
    if (result is! Map<String, dynamic>) throw const FormatException();
    final geometry = result['geometry'];
    final location =
        geometry is Map<String, dynamic> ? geometry['location'] : null;
    if (location is! Map<String, dynamic>) throw const FormatException();
    final latitude = (location['lat'] as num?)?.toDouble();
    final longitude = (location['lng'] as num?)?.toDouble();
    if (latitude == null || longitude == null) throw const FormatException();
    return _ResolvedPlace(
      address: result['formatted_address']?.toString() ?? '',
      position: LatLng(latitude, longitude),
    );
  }

  Future<String> reverseGeocode(LatLng position) async {
    final json = await _getJson(
      Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
        'latlng': '${position.latitude},${position.longitude}',
        'key': _googleMapsApiKey,
      }),
    );
    _ensureSuccess(json);
    final results = json['results'];
    if (results is! List || results.isEmpty) throw const FormatException();
    final first = results.first;
    if (first is! Map<String, dynamic>) throw const FormatException();
    final address = first['formatted_address']?.toString().trim() ?? '';
    if (address.isEmpty) throw const FormatException();
    return address;
  }

  Future<_ResolvedPlace> geocodeAddress(String address) async {
    final json = await _getJson(
      Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
        'address': address,
        'key': _googleMapsApiKey,
        'components': 'country:IN',
      }),
    );
    _ensureSuccess(json);
    final results = json['results'];
    if (results is! List || results.isEmpty) throw const FormatException();
    final first = results.first;
    if (first is! Map<String, dynamic>) throw const FormatException();
    final geometry = first['geometry'];
    final location =
        geometry is Map<String, dynamic> ? geometry['location'] : null;
    if (location is! Map<String, dynamic>) throw const FormatException();
    final latitude = (location['lat'] as num?)?.toDouble();
    final longitude = (location['lng'] as num?)?.toDouble();
    if (latitude == null || longitude == null) throw const FormatException();
    return _ResolvedPlace(
      address: first['formatted_address']?.toString() ?? address,
      position: LatLng(latitude, longitude),
    );
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(uri).timeout(_requestTimeout);
      return await _decodeResponse(
        await request.close().timeout(_requestTimeout),
        uri,
      );
    } finally {
      client.close(force: true);
    }
  }

  Future<Map<String, dynamic>> _postJson(
    Uri uri, {
    required Map<String, dynamic> body,
    required Map<String, String> headers,
  }) async {
    final client = HttpClient();
    try {
      final request = await client.postUrl(uri).timeout(_requestTimeout);
      request.headers.contentType = ContentType.json;
      headers.forEach(request.headers.set);
      request.write(jsonEncode(body));
      return await _decodeResponse(
        await request.close().timeout(_requestTimeout),
        uri,
      );
    } finally {
      client.close(force: true);
    }
  }

  Future<Map<String, dynamic>> _decodeResponse(
    HttpClientResponse response,
    Uri uri,
  ) async {
    final body = await utf8.decoder.bind(response).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException('Google Maps request failed', uri: uri);
    }
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) throw const FormatException();
    return decoded;
  }

  void _ensureSuccess(Map<String, dynamic> json) {
    final status = json['status']?.toString();
    if (status != 'OK' && status != 'ZERO_RESULTS') {
      throw StateError(json['error_message']?.toString() ?? status ?? 'ERROR');
    }
  }

  static const _requestTimeout = Duration(seconds: 10);
}

class _PlaceSuggestion {
  const _PlaceSuggestion({
    required this.placeId,
    required this.description,
    required this.primaryText,
    required this.secondaryText,
  });

  factory _PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    final prediction = json['placePrediction'];
    if (prediction is! Map<String, dynamic>) {
      return const _PlaceSuggestion(
        placeId: '',
        description: '',
        primaryText: '',
        secondaryText: '',
      );
    }
    final text = prediction['text'];
    final description =
        text is Map<String, dynamic> ? text['text']?.toString() ?? '' : '';
    final formatting = prediction['structuredFormat'];
    final structured = formatting is Map<String, dynamic>
        ? formatting
        : const <String, dynamic>{};
    final mainText = structured['mainText'];
    final secondaryText = structured['secondaryText'];
    return _PlaceSuggestion(
      placeId: prediction['placeId']?.toString() ?? '',
      description: description,
      primaryText: mainText is Map<String, dynamic>
          ? mainText['text']?.toString() ?? description
          : description,
      secondaryText: secondaryText is Map<String, dynamic>
          ? secondaryText['text']?.toString() ?? ''
          : '',
    );
  }

  factory _PlaceSuggestion.fromLegacyJson(Map<String, dynamic> json) {
    final formatting = json['structured_formatting'];
    final structured = formatting is Map<String, dynamic>
        ? formatting
        : const <String, dynamic>{};
    final description = json['description']?.toString() ?? '';
    return _PlaceSuggestion(
      placeId: json['place_id']?.toString() ?? '',
      description: description,
      primaryText: structured['main_text']?.toString() ?? description,
      secondaryText: structured['secondary_text']?.toString() ?? '',
    );
  }

  final String placeId;
  final String description;
  final String primaryText;
  final String secondaryText;
}

class _ResolvedPlace {
  const _ResolvedPlace({required this.address, required this.position});

  final String address;
  final LatLng position;
}

const _darkMapStyle = '''
[
  {"elementType":"geometry","stylers":[{"color":"#171717"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#92949A"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#171717"}]},
  {"featureType":"administrative","elementType":"geometry.stroke","stylers":[{"color":"#35424E"}]},
  {"featureType":"poi","elementType":"geometry","stylers":[{"color":"#1C2026"}]},
  {"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#CF9E24"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#283040"}]},
  {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#1A1F24"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#35424E"}]},
  {"featureType":"transit","elementType":"geometry","stylers":[{"color":"#1C2026"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#101820"}]},
  {"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#4FBAF0"}]}
]
''';
