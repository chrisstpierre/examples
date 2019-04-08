import React, { PureComponent, Fragment } from 'react';

import './ListPages.css'
import Thumbnail from '../Thumbnail'



class ListPages extends PureComponent {

  getNewPages() {
    const { created, focusPage } = this.props

    return created.map(filename => {
      const srcImage = `${process.env.REACT_APP_S3_URL}/${window.BASE_URL}/new/${filename}`
      return (
        <Thumbnail
          title={filename.split('.')[0]}
          newSrc={srcImage}
          focusPage={focusPage}
          key={filename} />
      )
    })
  }

  getChangedPages() {
    const { changed, focusPage } = this.props

    return changed.map(item => {
      const srcNewImage = `${process.env.REACT_APP_S3_URL}/${window.BASE_URL}/new/${item.path}`
      const srcDiffImage = `${process.env.REACT_APP_S3_URL}/${window.BASE_URL}/diffs/${item.path}`
      const srcOldImage = `${process.env.REACT_APP_S3_URL}/${window.BASE_URL}/old/${item.path}`

      return (
        <Thumbnail
          title={item.path.split('.')[0]}
          newSrc={srcNewImage}
          diffSrc={srcDiffImage}
          oldSrc={srcOldImage}
          focusPage={focusPage}
          key={item.path} />
      )
    })
  }

  getDeletedPages() {
    const { deleted, focusPage } = this.props

    return deleted.map(filename => {
      const srcImage = `${process.env.REACT_APP_S3_URL}/${window.BASE_URL}/old/${filename}`
      return (
        <Thumbnail
          title={filename.split('.')[0]}
          oldSrc={srcImage}
          focusPage={focusPage}
          key={filename} />
      )
    })
  }

  render() {
    const newPages = this.getNewPages()
    const changedPages = this.getChangedPages()
    const deletedPages = this.getDeletedPages()

    return (
      <Fragment>
        <h3>New Pages</h3>
        <div className="thumbnails-container">
          {newPages.length
            ? newPages
            : <p className="no-pages">No new pages</p>}
        </div>
        <h3>Page with changes</h3>
        <div className="thumbnails-container">
          {changedPages.length
            ? changedPages
            : <p className="no-pages">No new pages</p>}
        </div>
        <h3>Deleted pages</h3>
        <div className="thumbnails-container">
        {deletedPages.length
          ? deletedPages
          : <p className="no-pages">No deleted pages</p>}
        </div>
      </Fragment>
    )
  }
}

export default ListPages;
