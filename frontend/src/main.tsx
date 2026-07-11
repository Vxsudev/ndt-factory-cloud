import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './styles.css'
import App from './App'
import { VariantReviewShell } from './components/variant-review/VariantReviewShell'

const isVariantReviewRoute = window.location.hash.startsWith('#/variants')

function Root() {
  return isVariantReviewRoute ? <VariantReviewShell /> : <App />
}

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <Root />
  </StrictMode>,
)
