package me.markezine.lazyloader.core
{
	import flash.media.Sound;
	import flash.media.SoundLoaderContext;
	import flash.net.URLRequest;
	
	internal class CustomSound extends Sound{
		
		private var request:URLRequest;
		private var _uniqueId:String;
		
		public function CustomSound(request:URLRequest=null){
			this.request = request;
			super(request);
		}
		
		override public function load(request:URLRequest, context:SoundLoaderContext=null):void{
			this.request = request;
			super.load(request, context);
		}
		
		public function get relativeURL():String{
			return request ? request.url : "";
		}
		
		public function get uniqueId():String{
			return _uniqueId;
		}
		
		public function set uniqueId(value:String):void{
			_uniqueId = value;
		}
	}
}