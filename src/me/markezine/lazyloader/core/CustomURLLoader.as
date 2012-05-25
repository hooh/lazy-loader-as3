package me.markezine.lazyloader.core
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	internal class CustomURLLoader extends flash.net.URLLoader{
		
		private var request:URLRequest;
		private var _uniqueId:String;
		
		public function CustomURLLoader(request:URLRequest=null){
			this.request = request;
			super(request);
		}
		
		override public function load(request:URLRequest):void{
			this.request = request;
			super.load(request);
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