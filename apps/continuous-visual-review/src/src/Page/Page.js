import React, { PureComponent } from 'react';

import './Page.css'
import Slider from '../Slider'


class Page extends PureComponent {

  state = {
    showDiff: false
  }

  handleButtonDiff = () => {
    this.setState({
      showDiff: !this.state.showDiff
    })
  }

  renderPageDiff() {
    const {
      oldSrc,
      newSrc,
      diffSrc
    } = this.props

    if (this.state.showDiff)
      return <img src={diffSrc} alt="difference between the two pages" />
    else
      return <Slider imgLeft={oldSrc} imgRight={newSrc} />
  }

  renderButtons() {
    const textToggle = this.state.showDiff
      ? 'Show comparator'
      : 'Highlight differences'

    return (
      <div className="button-wrapper">
        <button onClick={this.props.displayList} className="button button-blue">Go back</button>
        {this.props.diffSrc && <button onClick={this.handleButtonDiff} className="button button-orange">{textToggle}</button>}
      </div>
    )
  }

  renderImages() {
    if (this.props.diffSrc)
      return this.renderPageDiff()
    else if (this.props.newSrc)
      return <img src={this.props.newSrc} alt="Screenshot of the new page" />
    else if (this.props.oldSrc)
      return <img src={this.props.oldSrc} alt="Screenshot of the deleted page" />
    return null
  }

  render() {
    return (
      <div className="Page">
        {this.renderButtons()}
        {this.renderImages()}
      </div>
    )

  }
}

export default Page;
