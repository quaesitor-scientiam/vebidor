module webdriver

pub struct EdgeNetworkConditions {
	pub:
		offline            bool
		latency            int
		download_throughput int
		upload_throughput   int
}

pub struct EdgeDeviceEmulation {
	pub:
		width  int
		height int
		scale  f32
}
