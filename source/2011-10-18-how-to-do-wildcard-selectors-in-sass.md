---
layout: post
title: How to do wildcard selectors with Sass
wip: true
---
#How to do wildcard selectors with Sass

To produce:
```css
.blah[class*='span']  {
  text-align: center;
}
```

use:

```css
.blah
  &[class*='span']
    text-align: center
```
