# Component + Hook Template

Canonical structure for the Structure rules (18–19): one component per file, visual-only components, behavior in custom hooks.

## `UserForm.tsx` — visual only

Renders and delegates. Contains: JSX, presentational prop wiring, and trivial inline state toggles only. No fetching, no business rules, no effect logic.

```tsx
import { useUserForm } from './useUserForm'

interface UserFormProps {
  initialName: string
  onCancel: () => void
}

export function UserForm({ initialName, onCancel }: UserFormProps) {
  const { name, isSubmitting, error, handleChange, handleSubmit } =
    useUserForm(initialName)

  return (
    <form onSubmit={handleSubmit}>
      <input value={name} onChange={(e) => handleChange(e.target.value)} />
      {error && <p role="alert">{error}</p>}
      <button disabled={isSubmitting}>Save</button>
      <button type="button" onClick={onCancel}>Cancel</button>
    </form>
  )
}
```

## `useUserForm.ts` — behavior

Owns state, actions, validation, effects, and error handling. One hook per component/concern; complex components compose several small hooks instead of one god-hook.

```ts
import { useCallback, useState } from 'react'
import type { FormEvent } from 'react'
import { saveUser } from './api'

interface UseUserFormResult {
  name: string
  isSubmitting: boolean
  error: string | null
  handleChange: (value: string) => void
  handleSubmit: (e: FormEvent) => void
}

export function useUserForm(initialName: string): UseUserFormResult {
  const [name, setName] = useState(initialName)
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const handleChange = useCallback((value: string) => {
    setName(value)
    setError(null)
  }, [])

  const handleSubmit = useCallback(async (e: FormEvent) => {
    e.preventDefault()
    if (!name.trim()) {
      setError('Name is required')
      return
    }
    setIsSubmitting(true)
    try {
      await saveUser(name)
    } catch {
      setError('Failed to save user')
    } finally {
      setIsSubmitting(false)
    }
  }, [name])

  return { name, isSubmitting, error, handleChange, handleSubmit }
}
```

## What this template enforces

- One exported component per file; its hook lives in a sibling `useXxx.ts`.
- The component imports the hook and renders; it implements no business logic.
- Fetching, validation, error state, and effects belong to the hook.
- Trivial inline toggles (`onClick={() => setOpen(true)}`) stay in the component.
- Behavior tests target the hook; render tests target the component.
