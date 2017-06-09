window.__MEMOTUBE = {
  rate: 1
};

var video = null;

function getVideo() {
  return document.getElementsByTagName('video')[0];
}

function playListener() {
  video.playbackRate = window.__MEMOTUBE.rate;
}

function loadVideo() {
  video = getVideo();
  video.playbackRate = window.__MEMOTUBE.rate;
  video.removeEventListener('play', playListener);
  video.addEventListener('play', playListener);
}

function changeSpeedRateTo(rate) {
  window.__MEMOTUBE.rate = rate;
  loadVideo();
}

function rewind() {
  video = getVideo();
  video.currentTime -= 10;
}

function pause() {
  video = getVideo();
  video.pause();
  return video.currentTime;
}

function play() {
  video = getVideo();
  video.play();
}

function applyInlinePlay() {
  video = getVideo();
  var attrList = ['webkit-playsinline', 'playsinline', 'controls'];
  attrList.forEach(function(attr) {
    video.setAttribute(attr, '');
  });
}


