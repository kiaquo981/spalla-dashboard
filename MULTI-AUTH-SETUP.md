# 🔐 Spalla Multi-Auth System Setup

**Status:** ✅ Implementado e pronto para deploy
**Data:** 2026-02-26
**Versão:** 2.0 (Multi-Login com Supabase Auth)

---

## 📋 O que foi implementado

### ✅ Backend (Python)
- [x] Integração com Supabase Auth (Gotrue)
- [x] Endpoints de signup/login/refresh
- [x] Google OAuth support
- [x] Password hashing com bcrypt (fallback PBKDF2)
- [x] JWT token management
- [x] Multi-method auth (Email + Google)

### ✅ Frontend (JavaScript)
- [x] Nova interface de login/signup
- [x] Gerenciamento de sessão
- [x] Google OAuth flow integration
- [x] Token refresh automático
- [x] Error handling melhorado

### ✅ Database (PostgreSQL via Supabase)
- [x] Tabela `user_profiles` com roles
- [x] RLS policies para auth
- [x] Trigger para auto-criar profile
- [x] Índices para performance

---

## 🚀 PASSO-A-PASSO: Como Aplicar

### **PASSO 1: Aplicar Auth Setup no Supabase**

1. Abra: https://app.supabase.com/projects/knusqfbvhsqworzyhvip/sql/editor
2. Clique em: **"New query"**
3. Copie TODO o conteúdo de: **02-AUTH-SETUP.sql**
4. Cole no editor
5. Clique em: **"Run"**
6. Aguarde: ~30 segundos ✅

**Resultado esperado:**
```
✅ Rows affected: 20+
✅ Tables created: user_profiles
✅ RLS policies: Applied
✅ Trigger: on_auth_user_created
```

---

### **PASSO 2: Criar 7 Usuários no Supabase Auth**

Abra: https://app.supabase.com/projects/knusqfbvhsqworzyhvip/auth/users

Para cada usuário abaixo, clique em: **"Add user"**

#### 👑 **ADMINS (2)**

1. **Kaique Azevedo**
   - Email: `kaique.azevedoo@outlook.com`
   - Senha: `[você escolhe uma forte]`
   - Role: `admin`

2. **ADM AllIn**
   - Email: `adm@allindigitalmarketing.com.br`
   - Senha: `[você escolhe uma forte]`
   - Role: `admin`

#### 👤 **USUÁRIOS (5)**

3. **Queila Trizotti**
   - Email: `queilatrizotti@gmail.com`
   - Senha: `[você escolhe uma forte]`
   - Role: `user`

4. **Hugo Nicchio**
   - Email: `hugo.nicchio@gmail.com`
   - Senha: `[você escolhe uma forte]`
   - Role: `user`

5. **Mariza**
   - Email: `mariza.rg22@gmail.com`
   - Senha: `[você escolhe uma forte]`
   - Role: `user`

6. **Lara Freitas**
   - Email: `santoslarafreitas@gmail.com`
   - Senha: `[você escolhe uma forte]`
   - Role: `user`

7. **Heitor**
   - Email: `heitorms15@gmail.com`
   - Senha: `[você escolhe uma forte]`
   - Role: `user`

---

### **PASSO 3: Atualizar Roles para Admins**

Após criar os 2 admins acima, execute este SQL para marcar como admin:

Abra: https://app.supabase.com/projects/knusqfbvhsqworzyhvip/sql/editor

```sql
-- Promote admins
UPDATE public.user_profiles
SET role = 'admin'
WHERE email IN (
  'kaique.azevedoo@outlook.com',
  'adm@allindigitalmarketing.com.br'
);

-- Verify
SELECT email, role FROM public.user_profiles ORDER BY email;
```

---

### **PASSO 4: Configurar Google OAuth (OPCIONAL)**

Se quiser login via Google:

1. Go to: https://console.cloud.google.com/
2. Create new project: "Spalla Dashboard"
3. Enable APIs: Google+ API, Gmail API
4. Create OAuth 2.0 credentials
5. Copy `Client ID` e `Client Secret`
6. Set em env vars:
   ```bash
   GOOGLE_OAUTH_CLIENT_ID=seu_client_id
   GOOGLE_OAUTH_CLIENT_SECRET=seu_client_secret
   ```

---

### **PASSO 5: Deploy para Vercel + Railway**

```bash
# Já está feito! Só precisa fazer push
git push

# Vercel auto-deploys frontend
# Railway auto-deploys backend
```

Aguarde ~2-3 minutos para deploy completar.

---

### **PASSO 6: Testar Login**

Abra: https://spalla-dashboard.vercel.app/

**Teste cada método:**

1. **Email + Senha**
   - Email: `kaique.azevedoo@outlook.com`
   - Senha: [a que você criou]
   - ✅ Deve entrar no dashboard

2. **Google OAuth** (se configurado)
   - Clique em: "Entrar com Google"
   - Use sua conta Google
   - ✅ Deve criar sesão automática

3. **Logout**
   - Menu → Sair
   - ✅ Deve voltar para login

---

## 🔑 Segurança Implementada

### ✅ Senha
- [x] Hasheadas com bcrypt
- [x] Mínimo 8 caracteres
- [x] Never stored in plaintext

### ✅ Tokens
- [x] JWT com 24h expiration
- [x] Refresh token support
- [x] Timing-safe comparison
- [x] HMAC-SHA256 signing

### ✅ OAuth
- [x] Google OAuth 2.0 flow
- [x] PKCE protection (if configured)
- [x] Redirect URI validation

### ✅ Database
- [x] RLS policies for user_profiles
- [x] Role-based access control
- [x] Session validation
- [x] User isolation

---

## 📊 User Roles

| Role | Permissões | Usuários |
|------|-----------|----------|
| **admin** | Full system access, user management | Kaique, ADM AllIn |
| **user** | Dashboard, data, tasks | Queila, Hugo, Mariza, Lara, Heitor |

---

## ⚙️ Próximos Passos (OPCIONAL)

### [ ] Google OAuth Production
- Configure Google Cloud credentials
- Test OAuth flow end-to-end

### [ ] 2FA (Two-Factor Authentication)
- Add TOTP via Supabase
- SMS verification support

### [ ] Admin Dashboard
- User management UI
- Role assignment panel
- Activity logging

### [ ] Social Login
- GitHub OAuth
- Microsoft OAuth
- Apple Sign-In

---

## 🐛 Troubleshooting

### Problema: "Email already registered"
**Solução:** User já existe. Tente outro email ou faça reset de senha.

### Problema: "Invalid password"
**Solução:** Senha < 8 caracteres. Tente novamente com senha mais longa.

### Problema: "Google login not working"
**Solução:** Configure GOOGLE_OAUTH_CLIENT_ID em env vars.

### Problema: "Sessão expirou"
**Solução:** Automático! Refresh token vai renovar. Se não funcionar, faça login novamente.

---

## 📞 Suporte

Se algo não funcionar:
1. Check Supabase logs: https://app.supabase.com/projects/knusqfbvhsqworzyhvip/logs/editor
2. Check Railway logs: https://railway.app/project/[project-id]/logs
3. Check browser console: F12 → Console tab

---

**Status:** ✅ Pronto para produção!

**Próximo passo:** PASSO 1 acima (Aplicar 02-AUTH-SETUP.sql)
