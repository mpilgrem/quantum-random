module Quantum.Random.Mutex where

import Control.Concurrent.MVar (MVar, newMVar, takeMVar, putMVar)
import Control.Concurrent      (forkIO, ThreadId)

-- | A data type to coordinate access to the local files, implemented with an `MVar` @()@. When the
--   unit is present, access is available. IO operations that need access to the store or settings
--   file remove it from the `MVar` before doing so, and then replace it when they're done. Then
--   whenever two such operations might otherwise interfere, they will instead wait their turn to
--   obtain the access. This functionality is implemented with 'initAccessControl' and 'withAccess'.
--
--   Secondarily, it also contains another `MVar` @()@ used to prevent premature program exit when
--   a forked thread is running, implemented as 'forkSafely' and 'exitSafely'. The @qrand@
--   executable uses this to ensure that a concurrent operation to add data from ANU can finish.
data AccessControl = AccessControl {
  accessControl :: MVar (),
  exitControl   :: MVar ()
}

-- | Initiate the access control system.
initAccessControl :: IO AccessControl
initAccessControl = AccessControl <$> newMVar () <*> newMVar ()

-- | Perform the supplied IO action only when access is granted.
withAccess :: AccessControl -> IO a -> IO a
withAccess (AccessControl ac _) io = do
  _ <- takeMVar ac
  x <- io
  putMVar ac ()
  pure x

-- | Perform the supplied IO action while preventing premature program exit in conjunction
--   with 'exitSafely'.
holdExitWhile :: AccessControl -> IO a -> IO a
holdExitWhile (AccessControl _ ex) io = do
  _ <- takeMVar ex
  x <- io
  putMVar ex ()
  pure x

-- | Perform the supplied IO action in a new thread while preventing premature program exit
--   in conjunction with 'exitSafely'.
forkSafely :: AccessControl -> IO () -> IO ThreadId
forkSafely acc io = forkIO (holdExitWhile acc io)

-- | Exit with this operation to ensure a thread forked with 'forkSafely' can finish before
--   @main@ returns.
exitSafely :: AccessControl -> IO ()
exitSafely = return . takeMVar =<< exitControl
