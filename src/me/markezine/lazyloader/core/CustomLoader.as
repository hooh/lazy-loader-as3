package me.markezine.lazyloader.core
{
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	
	internal class CustomLoader extends Loader{
		private var request:URLRequest;
		private var _uniqueId:String;
		
		public function CustomLoader(){
			super();
		}
		
		override public function load(request:URLRequest, context:LoaderContext=null):void{
			this.request = request;
			if(!context) context = new LoaderContext(true);
			super.load(request, context);
		}
		
		public function get relativeURL():String{
			return request ? request.url: "";
		}
		
		public function get uniqueId():String{
			return _uniqueId;
		}
		
		public function set uniqueId(value:String):void{
			_uniqueId = value;
		}
	}
}