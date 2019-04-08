import React from 'react';

import './Thumbnail.css'


const Thumbnail = ({ diffSrc, oldSrc, newSrc, focusPage, title }) => {
  const srcForThumbnail =
    diffSrc ? diffSrc :
    oldSrc ? oldSrc :
    newSrc ? newSrc : null

  return (
    <div
      className="thumbnail"
      onClick={() => focusPage({diffSrc,oldSrc,newSrc})}>
        <img src={srcForThumbnail} alt="thumbnail page change" />
        {title}
    </div>
  )
}

export default Thumbnail;
