const char INDEX_HTML[] PROGMEM = R"=====(
<!DOCTYPE html>
<html>
	<head>
		<meta charset="UTF-8">
    <link rel="icon" href="/favicon.ico">
    <style>
      p
      {
        margin: 0px;
      }
      #list
      {
        width: 500px;
      }
      #source
      {
        width: 500px;
        height : 500px;
        display: flex;
        align-items: center;
        justify-content: center;        
      }
      #video,  #image
      {
        max-width: 500px;
        max-height: 500px;
      }
      #destination
      {
        width: 500px;
        text-align: center;      
      }
      #preview
      {
        width: 500px;
        border-radius: 100%;
      }
      .span40
      {
        display: inline-block;
        width:40px;
      }
      
    </style>
	</head>

	<body>

	<h1>POV Display Interface</h1>
	<div>
    <p>
       Add Files: 
       <input id="input" type="file" accept="image/*,video/*" multiple> 
    </p>
  </div>
	<div>
    <select id="list" size="10">
    </select>  
  </div>
	<div>
    <p>
       <button type="button" id="list_up">Up</button>  
       <button type="button" id="list_down">Down</button>  
       <button type="button" id="list_remove">Remove</button>  
       Auto play: 
       <input type="checkbox" id="auto"> 
       Interval: 
       <select id="interval">
        <option value="1">1s</option>
        <option value="2">2s</option>
        <option value="5" selected>5s</option>
        <option value="10">10s</option>
      </select>      
    </p>
  </div>
  
	<h1>Source</h1>
	<div id="source">
      <video id="video" controls autoplay style="display: none"></video>
      <img id="image" src="" style="display: none">
       
  </div>
	<h1>Settings</h1>
  <div>
    <p>
      Frame position: 
      <select id="mode">
        <option value="fill">Fill</option>
        <option value="fita">Fit square</option>
        <option value="fitc">Fit circle</option>
        <option value="stetch">Stetch</option>
      </select> 
    <p>
    </p>
      Set RpS: <span id="rps_set_span"></span>
    <p>
    </p>
      <input type="range" min="50" max="600" value="240" id="rps_set" style="width: 500px;">
    </p>
    </p>
  </div>
	<h1>Destination</h1>
  <div id="destination">
    <p>
      RpS: 
      <span id="rps" class="span40"> XX.X</span> 
      <span class="span40"> </span>FPS: 
      <span id="fps" class="span40"> XX.X</span>
    </p>
    <p>
    <span class="span40"> </span>
    </p>
    <canvas id="preview"> </canvas>
  </div>

  
  <script>
    var R=131;
    var URL = window.URL || window.webkitURL;
    Object.defineProperty(HTMLMediaElement.prototype, 'playing', {
        get: function(){
            return !!(this.currentTime > 0 && !this.paused && !this.ended && this.readyState > 2);
        }
    })
    
    document.querySelector('#input').addEventListener('change',function (event){
      for(i=0;i<this.files.length;i++){
        var file=this.files[i];
        var fileURL = URL.createObjectURL(file);
        console.log(file);

        var opt = document.createElement('option');
        opt.appendChild( document.createTextNode(file.name) );
        opt.value = fileURL; 
        opt.setAttribute("type", file.type);
        opt.setAttribute("class", file.type.split("/")[0]);
        document.querySelector('#list').appendChild(opt);         
        
      }
      this.value="";
    });
    document.querySelector('#list_up').addEventListener('click', function(event){      
      var index= document.querySelector('#list').selectedIndex;
      if(index<=0) return;
      var option=document.querySelector('#list').selectedOptions[0];
      document.querySelector('#list').remove(index);      
      document.querySelector('#list').add(option,index-1);
    });
    document.querySelector('#list_down').addEventListener('click', function(event){
      var index= document.querySelector('#list').selectedIndex;
      if(index==-1) return;
      var option=document.querySelector('#list').selectedOptions[0];
      document.querySelector('#list').remove(index);
      document.querySelector('#list').add(option,index+1);
    });
    document.querySelector('#list_remove').addEventListener('click', function(event){
      var index= document.querySelector('#list').selectedIndex;
      if(index==-1) return;
      document.querySelector('#list').remove(index);
    });
    
    
    
    
    var source = null;
    var source_type = "";
    
    document.querySelector('#list').addEventListener('change', function(event)
    {
      document.querySelector('#video').style.display="none";
      document.querySelector('#video').pause();
      document.querySelector('#image').style.display="none";

      if(document.querySelector('#list').selectedIndex==-1) return;

      var option=document.querySelector('#list').selectedOptions[0];
      source_type=option.getAttribute("class");
      switch(source_type) {
        case "video":
          source = document.querySelector('#video');  
          source.src = option.value;
          break;
        case "image":
          source = document.querySelector('#image');  
          source.src = option.value;
          break;
        default:
          source=null;
          source_type="";
      };
      source.style.display="block";
    });

    (function autoPlay(){
      setTimeout(autoPlay, 1000 * document.querySelector('#interval').value);      
      if(document.querySelector('#auto').checked==false) return;
      switch(source_type) {
        case "video":
          if(document.querySelector('#video').playing) return;
          break;
      };
      console.log("Auto Inrement next!");
      document.querySelector('#list').selectedIndex+=1;
      document.querySelector('#list').dispatchEvent(new Event('change'));
    })();

    
    var canvas = document.querySelector('#preview');
    canvas.height = R;
    canvas.width  = R;
    var ctx = canvas.getContext('2d');
    ctx.imageSmoothingEnabled = true;
    var ticks=0;
    var mode ="fill";
    
    
    setInterval(function(){
      ctx.beginPath();
      ctx.rect(0, 0, R, R);
      ctx.fillStyle = "black";
      ctx.fill();
      
      if(source==null) return;
      
      var sw=0;
      var sh=0;
      
      switch(source_type) {
        case "video":
          sw=source.videoWidth;
          sh=source.videoHeight;
          break;
        case "image":
          sw=source.naturalWidth;
          sh=source.naturalHeight;
          break;
        default:
          return;
      };
      
      
      switch(mode) {
        case "fill":
          if(sw>sh){
            ctx.drawImage(source, (sw-sh)/2, 0, sh,sh, 0, 0, R, R);
          }
          else
          {
            ctx.drawImage(source, 0,(sh-sw)/2, sw, sw, 0, 0, R, R);
          }
          break;
        case "fita":
          if(sw>sh){
            ctx.drawImage(source, 0, -(sw-sh)/2, sw,sw, 0, 0, R, R);
          }
          else
          {
            ctx.drawImage(source, -(sh-sw)/2, 0, sh,sh, 0, 0, R, R);
          }
          break;
        case "fitc":
          var ratio= sw / sh;
          var length=R/Math.sqrt(Math.pow(ratio,2)+1)
          var x=length*ratio;
          var y=length;
          console.log(x,y)
          ctx.drawImage(source, 0, 0, sw,sh, (R-x)/2, (R-y)/2, x, y);
          break;
        default:
          ctx.drawImage(source, 0, 0, sw,sh, 0, 0, R, R);
      }       

      ticks++;
    }, 1);

    setInterval(function(){
      console.log(ticks+" FPS");
      ticks=0;
      //update Mode
      var e =document.querySelector('#mode');
      mode=e.options[e.selectedIndex].value;
      
    }, 1000);
    
    document.querySelector('#rps_set').addEventListener('input',function() {
      document.querySelector('#rps_set_span').innerHTML = (this.value/10).toFixed(1);
    });
    document.querySelector('#rps_set').dispatchEvent(new Event('input'));
        
    
        
  </script>  
	</body>
</html>
)=====";