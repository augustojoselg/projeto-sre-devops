# 💾 Arquivos de Backup

Esta pasta contém arquivos temporários e de backup do projeto.

## 📁 Estrutura

- **`backup-project.ps1`** - Script PowerShell para backup do projeto
- **`COMMIT_INSTRUCTIONS.md`** - Instruções antigas de commit
- **`README.md`** - Este arquivo

## 🚀 Como usar

### Backup automático:
```powershell
.\backup-project.ps1
```

### Backup manual:
```powershell
# Criar backup com timestamp
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupPath = "backup_$timestamp"
# ... lógica de backup
```

## 📋 Arquivos incluídos

- Scripts de backup
- Documentação antiga
- Arquivos temporários
- Configurações de backup

## 🔧 Manutenção

- **Limpeza mensal** - Remover backups antigos
- **Verificação** - Testar scripts de backup
- **Atualização** - Manter scripts funcionais

## ⚠️ Importante

Esta pasta contém arquivos temporários que podem ser deletados sem afetar o projeto principal.
