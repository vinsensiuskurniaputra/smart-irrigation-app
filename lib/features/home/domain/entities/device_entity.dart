class DeviceEntity {
	final int id;
	final String deviceName;
	final String deviceCode;
	final String status;

	const DeviceEntity({
		required this.id,
		required this.deviceName,
		required this.deviceCode,
		required this.status,
	});

	bool get isOnline => status.toLowerCase() == 'online';
}
