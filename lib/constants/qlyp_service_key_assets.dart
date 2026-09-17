/// Bundled vehicle preview assets keyed by Firestore `service_key` (tier slug).
class QlypServiceKeyAssets {
  QlypServiceKeyAssets._();

  static const String packagePrefix =
      'packages/qlyp_core/assets/images/vehicles/';

  /// Normalizes admin / Firestore `service_key` values to lookup slugs.
  static String? normalizeServiceKey(String? raw) {
    if (raw == null) return null;
    var key = raw.trim().toLowerCase();
    if (key.isEmpty) return null;
    key = key.replaceAll('-', '_').replaceAll(' ', '_');
    if (key.startsWith('squad5')) key = 'squad_5';
    if (key.startsWith('squad6')) key = 'squad_6';
    if (key == 'unlocker') key = 'dbloc';
    if (key == 'bloc_hd') key = 'bloc';
    if (key == 'bite' || key == 'qlyp_bite') key = 'qlyp_bite';
    if (key == 'parcel' || key == 'qlyp_parcel') key = 'qlyp_parcel';
    if (key == 'boost') key = 'boost_light';
    if (key == 'towing' || key == 'towing_light') key = 'towing_light';
    if (key == 'towing_heavy') key = 'towing_hd';
    return key;
  }

  /// Full Flutter asset path for [serviceKey], or null when unknown / no file.
  static String? assetPathForServiceKey(String? serviceKey) {
    final key = normalizeServiceKey(serviceKey);
    if (key == null) return null;
    final filename = _filenameByServiceKey[key];
    if (filename == null || filename.isEmpty) return null;
    return '$packagePrefix$filename';
  }

  static const Map<String, String> _filenameByServiceKey = {
    'access': 'access.webp',
    'access_e': 'access_e.webp',
    'access_xl': 'access_xl.webp',
    'apex': 'apex.webp',
    'bloc': 'bloc_hd.webp',
    'boost_light': 'boost_light.webp',
    'boost_hd': 'boost_hd.webp',
    'byte': 'byte.webp',
    'cargo': 'cargo.webp',
    'core': 'core.webp',
    'dbloc': 'dbloc.webp',
    'galaxy': 'galaxy.webp',
    'luxe': 'luxe.webp',
    'max': 'max.webp',
    'mega': 'mega.webp',
    'qlyp_bite': 'qlyp_bite.webp',
    'qlyp_parcel': 'qlyp_parcel.webp',
    'relax': 'relax.webp',
    'relax_e': 'relax_e.webp',
    'squad_5': 'squad_5.webp',
    'squad_6': 'squad_6.webp',
    'tera': 'tera.webp',
    'titan': 'titan.webp',
    'towing_light': 'towing_light.webp',
    'towing_hd': 'towing_hd.webp',
    'volt': 'volt.webp',
    'zenith': 'zenith.webp',
    'zip': 'zip.webp',
  };
}
